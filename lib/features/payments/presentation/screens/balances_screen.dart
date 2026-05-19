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

class _Bal {
  final String label;
  final String from;
  final String to;
  final double amount;
  final bool isPositive;
  final bool isSettled;
  final bool isMainEntry;

  const _Bal({
    required this.label,
    required this.from,
    required this.to,
    required this.amount,
    required this.isPositive,
    required this.isSettled,
    required this.isMainEntry,
  });
}

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({
    super.key,
    required this.trip,
    required this.tripUserMap,
  });

  final TripModel trip;
  final Map<String, TripMemberModel> tripUserMap;

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  List<_Bal> _items = [];

  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();

    _build();
  }

  void _build() {
    final balances = SettleUpService.balances(widget.trip);

    final items = <_Bal>[];

    for (final b in balances) {
      final tu = widget.tripUserMap[b.user];

      if (tu == null || !tu.involved) continue;

      if (b.amount == 0.0) {
        items.add(
          _Bal(
            label: '${tu.name} is settled up',
            from: b.user,
            to: '',
            amount: 0,
            isPositive: true,
            isSettled: true,
            isMainEntry: true,
          ),
        );
      } else {
        items.add(
          _Bal(
            label: '${tu.name} ${b.isPositive ? 'gets back' : 'owes'}',
            from: b.user,
            to: '',
            amount: b.amount,
            isPositive: b.isPositive,
            isSettled: false,
            isMainEntry: true,
          ),
        );

        for (final entry in b.paid) {
          final from = b.isPositive ? entry.user : b.user;

          final to = b.isPositive ? b.user : entry.user;

          items.add(
            _Bal(
              label: '${widget.tripUserMap[from]?.name ?? ''} owes ',
              from: from,
              to: to,
              amount: entry.amount,
              isPositive: b.isPositive,
              isSettled: false,
              isMainEntry: false,
            ),
          );
        }
      }
    }

    setState(() {
      _items = items;

      _expanded = List.filled(
        items.length,
        false,
      );
    });
  }

  void _toggleSection(int index) {
    Haptics.medium();

    setState(() {
      int i = index;

      _expanded[i] = !_expanded[i];

      i++;

      while (i < _items.length && !_items[i].isMainEntry) {
        _expanded[i] = _expanded[index];

        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

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
                10,
              ),
              child: Row(
                children: [
                  _topActionButton(
                    context,
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(
                      context,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Balances',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // BODY
            // =========================

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  28,
                ),
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final item = _items[index];

                  if (item.isMainEntry) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: GestureDetector(
                        onTap: () => _toggleSection(index),
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 220,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              28,
                            ),

                            // GLASS
                            color: colorScheme.surface.withOpacity(
                              theme.brightness == Brightness.dark ? 0.90 : 0.96,
                            ),

                            border: Border.all(
                              color: item.isSettled
                                  ? colorScheme.primary.withOpacity(0.12)
                                  : (item.isPositive
                                          ? colorScheme.primary
                                          : AppColors.amber)
                                      .withOpacity(0.12),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: (item.isPositive
                                        ? colorScheme.primary
                                        : AppColors.amber)
                                    .withOpacity(
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
                          child: Column(
                            children: [
                              Row(
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
                                        id: widget
                                            .tripUserMap[item.from]!.name),
                                  ),

                                  const SizedBox(width: 16),

                                  // =========================
                                  // TEXT
                                  // =========================

                                  Expanded(
                                    child: item.isSettled
                                        ? Text(
                                            item.label,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        : RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: item.label,
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ' ₹${item.amount.toStringAsFixed(2)}',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    color: item.isPositive
                                                        ? colorScheme.primary
                                                        : AppColors.amber,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' in total',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),

                                  const SizedBox(width: 12),

                                  // =========================
                                  // TRAILING
                                  // =========================

                                  item.isSettled
                                      ? Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorScheme.primary
                                                .withOpacity(0.12),
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                        )
                                      : AnimatedRotation(
                                          turns: _expanded[index] ? 0.5 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 28,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.72),
                                          ),
                                        ),
                                ],
                              ),

                              // =========================
                              // EXPANDED CHILDREN
                              // =========================

                              if (_expanded[index] && !item.isSettled) ...[
                                const SizedBox(height: 18),
                                ..._buildChildren(index),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // CHILD ITEMS
  // =========================

  List<Widget> _buildChildren(int parentIndex) {
    final widgets = <Widget>[];

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    int i = parentIndex + 1;

    while (i < _items.length && !_items[i].isMainEntry) {
      final item = _items[i];

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i == _items.length - 1 ||
                    (i + 1 < _items.length && _items[i + 1].isMainEntry)
                ? 0
                : 14,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colorScheme.surface.withOpacity(
                0.55,
              ),
              border: Border.all(
                color: (item.isPositive ? colorScheme.primary : AppColors.amber)
                    .withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                // =========================
                // SMALL AVATAR
                // =========================

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ProfileImage(
                    id: widget.tripUserMap[item.from]?.name ?? 'A',
                  ),
                ),

                const SizedBox(width: 14),

                // =========================
                // TEXT
                // =========================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: item.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '₹${item.amount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: item.isPositive
                                    ? colorScheme.primary
                                    : AppColors.amber,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'to ${widget.tripUserMap[item.to]?.name ?? ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.68),
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

                GestureDetector(
                  onTap: () async {
                    Haptics.medium();

                    final res = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordPaymentScreen(
                          tripUserMap: widget.tripUserMap,
                          from: item.from,
                          to: item.to,
                          amount: item.amount,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (res == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: NeonGlow(
                    color: colorScheme.primary,
                    radius: 14,
                    spread: 0,
                    glowOpacity: 0.16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.88),
                          ],
                        ),
                      ),
                      child: Text(
                        'Settle',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      i++;
    }

    return widgets;
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
