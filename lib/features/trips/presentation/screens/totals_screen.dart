import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class TotalsScreen extends StatelessWidget {
  const TotalsScreen({
    super.key,
    required this.name,
    required this.paidByMe,
    required this.paidForMe,
    required this.total,
  });

  final String name;

  final double paidByMe;

  final double paidForMe;

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final youAreOwed = paidByMe - paidForMe;

    final isPositive = youAreOwed >= 0;

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
                8,
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
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // SUMMARY CARD
                    // =========================

                    NeonGlow(
                      color: isPositive ? colorScheme.primary : AppColors.amber,
                      radius: 30,
                      spread: -8,
                      glowOpacity: 0.18,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),

                          // GLASS
                          color: colorScheme.surface.withOpacity(
                            theme.brightness == Brightness.dark ? 0.92 : 0.97,
                          ),

                          border: Border.all(
                            color: (isPositive
                                    ? colorScheme.primary
                                    : AppColors.amber)
                                .withOpacity(0.14),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: (isPositive
                                      ? colorScheme.primary
                                      : AppColors.amber)
                                  .withOpacity(
                                theme.brightness == Brightness.dark
                                    ? 0.12
                                    : 0.05,
                              ),
                              blurRadius: 30,
                              spreadRadius: -8,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (isPositive
                                            ? colorScheme.primary
                                            : AppColors.amber)
                                        .withOpacity(0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Icon(
                                isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 42,
                                color: isPositive
                                    ? colorScheme.primary
                                    : AppColors.amber,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              isPositive
                                  ? 'You are owed overall'
                                  : 'Your overall share',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.70),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '₹${youAreOwed.abs().toStringAsFixed(2)}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isPositive
                                    ? colorScheme.primary
                                    : AppColors.amber,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =========================
                    // STATS
                    // =========================

                    _modernStatCard(
                      context,
                      title: 'Total group spending',
                      subtitle: 'Overall expenses in this group',
                      amount: total,
                      icon: Icons.payments_rounded,
                      color: colorScheme.primary,
                    ),

                    const SizedBox(height: 14),

                    _modernStatCard(
                      context,
                      title: 'You paid',
                      subtitle: 'Money paid by you',
                      amount: paidByMe,
                      icon: Icons.account_balance_wallet_rounded,
                      color: colorScheme.primary,
                    ),

                    const SizedBox(height: 14),

                    _modernStatCard(
                      context,
                      title: 'Your share',
                      subtitle: 'Your share of all expenses',
                      amount: paidForMe,
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.amber,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // MODERN STAT CARD
  // =========================

  Widget _modernStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withOpacity(
          theme.brightness == Brightness.dark ? 0.90 : 0.97,
        ),
        border: Border.all(
          color: color.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(
              theme.brightness == Brightness.dark ? 0.08 : 0.03,
            ),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          // =========================
          // ICON
          // =========================

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.18),
                  color.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.12),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // =========================
          // TEXT
          // =========================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.66),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // AMOUNT
          // =========================

          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
              size: 22,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
