// choose_payment_by_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/payments/presentation/screens/choose_payment_for_screen.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

class ChoosePaymentByScreen extends StatelessWidget {
  const ChoosePaymentByScreen({
    super.key,
    required this.tripUserMap,
  });

  final Map<String, TripMemberModel> tripUserMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final users = tripUserMap.values.where((e) => e.involved).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                12,
              ),
              child: Row(
                children: [
                  _topActionButton(
                    context,
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment From',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choose who paid',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // LIST
            // =========================

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  24,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 14,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        Haptics.medium();

                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChoosePaymentForScreen(
                              tripUserMap: tripUserMap,
                              from: user.id,
                            ),
                          ),
                        );

                        if (!context.mounted) return;

                        if (res == true) {
                          Navigator.pop(
                            context,
                            true,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: colorScheme.surface.withOpacity(
                            theme.brightness == Brightness.dark ? 0.92 : 0.97,
                          ),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(
                                theme.brightness == Brightness.dark
                                    ? 0.10
                                    : 0.04,
                              ),
                              blurRadius: 28,
                              spreadRadius: -8,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // =========================
                            // PROFILE
                            // =========================

                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  36,
                                ),
                              ),
                              child: ProfileImage(
                                id: user.name,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // =========================
                            // NAME
                            // =========================

                            Expanded(
                              child: Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TOP ACTION BUTTON
  // =========================

  Widget _topActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(
                0.72,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.08),
              ),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
