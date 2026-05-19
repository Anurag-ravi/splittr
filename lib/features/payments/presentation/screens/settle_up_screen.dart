import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/services/settle_up_service.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class SettleUpScreen extends StatelessWidget {
  const SettleUpScreen({
    super.key,
    required this.trip,
    required this.tripUserMap,
  });

  final TripModel trip;
  final Map<String, TripMemberModel> tripUserMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final triads = SettleUpService.triads(trip);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  _topActionButton(
                    context,
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settle Up',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // BODY
            // =========================

            Expanded(
              child: triads.isEmpty
                  ? _emptyState(context)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        24,
                      ),
                      itemCount: triads.length,
                      itemBuilder: (_, i) {
                        final t = triads[i];

                        final fromUser = tripUserMap[t.from];

                        final toUser = tripUserMap[t.to];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: () async {
                              Haptics.medium();

                              final res = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecordPaymentScreen(
                                    tripUserMap: tripUserMap,
                                    from: t.from,
                                    to: t.to,
                                    amount: t.amount,
                                  ),
                                ),
                              );

                              if (!context.mounted) return;

                              if (res == true) {
                                Navigator.pop(context, true);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),

                                // GLASS EFFECT
                                color: colorScheme.surface.withOpacity(
                                  theme.brightness == Brightness.dark
                                      ? 0.90
                                      : 0.96,
                                ),

                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(
                                    0.10,
                                  ),
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(
                                      theme.brightness == Brightness.dark
                                          ? 0.10
                                          : 0.04,
                                    ),
                                    blurRadius: 28,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      theme.brightness == Brightness.dark
                                          ? 0.18
                                          : 0.04,
                                    ),
                                    blurRadius: 22,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // =========================
                                  // AVATAR
                                  // =========================

                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: ProfileImage(
                                      id: fromUser?.name ?? 'A',
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // =========================
                                  // TEXT
                                  // =========================

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${fromUser?.name ?? ''} ',
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'owes ',
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '₹${t.amount.toStringAsFixed(2)}',
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  color: AppColors.amber,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'to ${toUser?.name ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme
                                                .textTheme.bodyMedium?.color
                                                ?.withOpacity(0.72),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // =========================
                                  // BUTTON
                                  // =========================

                                  NeonGlow(
                                    color: colorScheme.primary,
                                    radius: 16,
                                    spread: 0,
                                    glowOpacity: 0.18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.primary.withOpacity(
                                              0.88,
                                            ),
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Settle',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
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
        borderRadius: BorderRadius.circular(16),
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
                color: colorScheme.primary.withOpacity(
                  0.08,
                ),
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

  // =========================
  // EMPTY STATE
  // =========================

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.handshake_rounded,
                size: 62,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Everyone is settled',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No pending balances remaining in this group.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
