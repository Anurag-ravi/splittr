import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class ChoosePaidByScreen extends StatefulWidget {
  const ChoosePaidByScreen({
    super.key,
    required this.tripUserMap,
    required this.paidBy,
    required this.amount,
  });

  final Map<String, TripMemberModel> tripUserMap;

  final List<By> paidBy;

  final double amount;

  @override
  State<ChoosePaidByScreen> createState() => _ChoosePaidByScreenState();
}

class _ChoosePaidByScreenState extends State<ChoosePaidByScreen> {
  late List<TripMemberModel> _users;

  late List<By> _multiplePaidBy;

  late List<TextEditingController> _controllers;

  bool _singlePaid = true;

  String _currentPaidUser = '';

  double _total = 0;

  @override
  void initState() {
    super.initState();

    _users = widget.tripUserMap.values.where((e) => e.involved).toList();

    _singlePaid = widget.paidBy.length == 1;

    _currentPaidUser = widget.paidBy[0].user;

    _multiplePaidBy = _users.map((e) {
      double amnt = 0;

      for (final b in widget.paidBy) {
        if (b.user == e.id && b.amount > 0) {
          amnt = b.amount;

          _total += amnt;

          break;
        }
      }

      return By(e.id, amnt, 0);
    }).toList();

    _controllers = _multiplePaidBy.map((b) {
      return TextEditingController(
        text: b.amount > 0 ? b.amount.toString() : '',
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }

    super.dispose();
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
            // =====================
            // HEADER
            // =====================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                10,
              ),
              child: Row(
                children: [
                  _topActionButton(
                    context,
                    icon: Icons.close_rounded,
                    onTap: () {
                      Navigator.pop(
                        context,
                        widget.paidBy,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who Paid?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          _singlePaid
                              ? 'Choose one payer'
                              : 'Split payment among members',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.textTheme.bodyMedium?.color?.withOpacity(
                              0.68,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_singlePaid)
                    GestureDetector(
                      onTap: () {
                        if ((_total - widget.amount).abs() > 0.01) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Amounts do not add up to ₹${widget.amount.toStringAsFixed(2)}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          return;
                        }

                        Navigator.pop(
                          context,
                          _multiplePaidBy
                              .where(
                                (b) => b.amount > 0,
                              )
                              .toList(),
                        );
                      },
                      child: NeonGlow(
                        color: colorScheme.primary,
                        radius: 18,
                        spread: -2,
                        glowOpacity: 0.16,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
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
                          child: Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // =====================
            // MODE TOGGLE
            // =====================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _modeButton(
                      context,
                      title: 'Single payer',
                      selected: _singlePaid,
                      onTap: () {
                        Haptics.medium();

                        setState(() {
                          _singlePaid = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modeButton(
                      context,
                      title: 'Multiple payers',
                      selected: !_singlePaid,
                      onTap: () {
                        Haptics.medium();

                        setState(() {
                          _singlePaid = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =====================
            // BODY
            // =====================

            Expanded(
              child: _singlePaid ? _singleList() : _multiList(),
            ),

            // =====================
            // FOOTER
            // =====================

            if (!_singlePaid)
              Container(
                margin: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20,
                ),
                padding: const EdgeInsets.all(
                  18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                  color: colorScheme.surface.withOpacity(
                    0.72,
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(
                      0.08,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(
                                0.66,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '₹${_total.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: colorScheme.outline.withOpacity(
                        0.12,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.amount - _total >= 0
                                ? 'Remaining'
                                : 'Exceeded',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(
                                0.66,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '₹${(widget.amount - _total).abs().toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: widget.amount - _total >= 0
                                  ? Colors.white
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =====================
  // SINGLE LIST
  // =====================

  Widget _singleList() {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        10,
        0,
        10,
        24,
      ),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        final selected = _currentPaidUser == user.id;

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: GestureDetector(
            onTap: () {
              Haptics.medium();

              Navigator.pop(
                context,
                [
                  By(
                    user.id,
                    widget.amount,
                    0,
                  ),
                ],
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  28,
                ),
                color: colorScheme.surface.withOpacity(
                  theme.brightness == Brightness.dark ? 0.92 : 0.97,
                ),
                border: Border.all(
                  color: selected
                      ? colorScheme.primary.withOpacity(
                          0.18,
                        )
                      : colorScheme.outline.withOpacity(
                          0.08,
                        ),
                ),
              ),
              child: Row(
                children: [
                  // PROFILE

                  Container(
                    width: 64,
                    height: 64,
                    child: ProfileImage(
                      id: user.name,
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  // TEXT

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          selected ? 'Currently selected' : 'Tap to select',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? colorScheme.primary
                                : theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(
                                    0.64,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          selected ? colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(
                                0.22,
                              ),
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================
  // MULTI LIST
  // =====================

  Widget _multiList() {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        10,
        0,
        10,
        24,
      ),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: Container(
            padding: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                28,
              ),
              color: colorScheme.surface.withOpacity(
                theme.brightness == Brightness.dark ? 0.92 : 0.97,
              ),
              border: Border.all(
                color: colorScheme.primary.withOpacity(
                  0.08,
                ),
              ),
            ),
            child: Row(
              children: [
                // PROFILE

                Container(
                  width: 64,
                  height: 64,
                  child: ProfileImage(
                    id: user.name,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                // NAME

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Enter contribution',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.64,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // INPUT

                SizedBox(
                  width: 110,
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                      color: colorScheme.surface.withOpacity(
                        0.72,
                      ),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(
                          0.08,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '₹',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                  r'^\d+\.?\d{0,2}',
                                ),
                              ),
                            ],
                            cursorColor: colorScheme.primary,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            onChanged: (input) {
                              setState(
                                () {
                                  _multiplePaidBy[index].amount =
                                      input.isNotEmpty
                                          ? double.parse(
                                              input,
                                            )
                                          : 0;

                                  _total = _multiplePaidBy.fold(
                                    0,
                                    (
                                      s,
                                      b,
                                    ) =>
                                        s + b.amount,
                                  );
                                },
                              );
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================
  // MODE BUTTON
  // =====================

  Widget _modeButton(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            18,
          ),
          color: selected
              ? colorScheme.primary.withOpacity(0.12)
              : colorScheme.surface.withOpacity(0.72),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withOpacity(0.24)
                : colorScheme.outline.withOpacity(0.08),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }

  // =====================
  // TOP ACTION BUTTON
  // =====================

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
              borderRadius: BorderRadius.circular(
                16,
              ),
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
}
