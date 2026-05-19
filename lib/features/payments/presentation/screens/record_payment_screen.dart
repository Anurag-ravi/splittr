import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/payments/presentation/providers/payment_providers.dart';
import 'package:splittr/features/payments/presentation/states/payment_state.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.tripUserMap,
    this.updating = false,
    this.paymentId = '',
    this.created,
  });

  final String from;

  final String to;

  final double amount;

  final Map<String, TripMemberModel> tripUserMap;

  final bool updating;

  final String paymentId;

  final DateTime? created;

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final _amountController = TextEditingController();

  String _amount = '0.00';

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.amount.toStringAsFixed(2) != '0.00') {
      _amount = widget.amount.toStringAsFixed(2);

      _amountController.text = _amount;
    }

    if (widget.updating && widget.created != null) {
      _selectedDate = widget.created!;
    }

    ref.listenManual<AsyncValue<PaymentSavedData?>>(
      paymentNotifierProvider,
      (_, next) {
        final controller = ref.read(
          paymentNotifierProvider.notifier,
        );

        next.whenOrNull(
          error: (e, _) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  duration: const Duration(seconds: 4),
                ),
              );
            });

            controller.reset();
          },
          data: (result) {
            if (result == null) return;

            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.updating ? 'Payment updated' : 'Payment added',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.pop(
                context,
                true,
              );
            });

            controller.reset();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();

    super.dispose();
  }

  String _timeStr(DateTime d) {
    int h = d.hour;

    final ampm = h >= 12 ? 'PM' : 'AM';

    if (h > 12) h -= 12;

    if (h == 0) h = 12;

    return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final paymentAsync = ref.watch(
      paymentNotifierProvider,
    );

    final controller = ref.read(
      paymentNotifierProvider.notifier,
    );

    final saving = paymentAsync.isLoading;

    final fromName = widget.tripUserMap[widget.from]!.name.trim();

    final toName = widget.tripUserMap[widget.to]!.name.trim();

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
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(
                      context,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.updating ? 'Update Payment' : 'Record Payment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: saving
                        ? null
                        : () {
                            FocusManager.instance.primaryFocus?.unfocus();

                            Haptics.medium();

                            if (_amountController.text.isEmpty) {
                              return;
                            }

                            controller.record(
                              fromTripUserId: widget.from,
                              toTripUserId: widget.to,
                              amount: double.parse(_amount),
                              tripUserMap: widget.tripUserMap,
                              created: _selectedDate,
                              paymentId:
                                  widget.updating ? widget.paymentId : null,
                            );
                          },
                    child: saving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: colorScheme.primary,
                            ),
                          )
                        : NeonGlow(
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

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  32,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // =========================
                    // PAYMENT CARD
                    // =========================

                    NeonGlow(
                      color: colorScheme.primary,
                      radius: 34,
                      spread: -10,
                      glowOpacity: 0.14,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            32,
                          ),
                          color: colorScheme.surface.withOpacity(
                            theme.brightness == Brightness.dark ? 0.92 : 0.97,
                          ),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(
                              0.10,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(
                                0.10,
                              ),
                              blurRadius: 34,
                              spreadRadius: -8,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // =========================
                            // PEOPLE ROW
                            // =========================

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _profileBubble(
                                  context,
                                  widget.from,
                                  fromName,
                                  colorScheme.primary,
                                ),
                                const SizedBox(width: 18),
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color:
                                        colorScheme.surface.withOpacity(0.80),
                                    border: Border.all(
                                      color:
                                          colorScheme.primary.withOpacity(0.10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: colorScheme.onSurface,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                _profileBubble(
                                  context,
                                  widget.to,
                                  toName,
                                  AppColors.error,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              '$fromName pays $toName',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // =========================
                            // AMOUNT INPUT
                            // =========================

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: colorScheme.surface.withOpacity(0.72),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                      color:
                                          colorScheme.primary.withOpacity(0.10),
                                    ),
                                    child: Icon(
                                      Icons.currency_rupee_rounded,
                                      color: colorScheme.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
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
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                      ),
                                      onChanged: (v) {
                                        setState(() {
                                          _amount = v.isEmpty ? '0.00' : v;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0.00',
                                        hintStyle: theme
                                            .textTheme.headlineMedium
                                            ?.copyWith(
                                          color: theme
                                              .textTheme.bodyMedium?.color
                                              ?.withOpacity(
                                            0.28,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // =========================
                            // DATE TIME
                            // =========================

                            Row(
                              children: [
                                Expanded(
                                  child: _modernPicker(
                                    context,
                                    icon: Icons.calendar_month_rounded,
                                    text:
                                        '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                                    onTap: () async {
                                      Haptics.medium();

                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );

                                      if (date != null) {
                                        setState(() {
                                          _selectedDate = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            _selectedDate.hour,
                                            _selectedDate.minute,
                                          ).toLocal();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _modernPicker(
                                    context,
                                    icon: Icons.access_time_rounded,
                                    text: _timeStr(
                                      _selectedDate,
                                    ),
                                    onTap: () async {
                                      Haptics.medium();

                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                          _selectedDate,
                                        ),
                                      );

                                      if (time != null) {
                                        setState(() {
                                          _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day,
                                            time.hour,
                                            time.minute,
                                          ).toLocal();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  }

  // =========================
  // PROFILE BUBBLE
  // =========================

  Widget _profileBubble(
    BuildContext context,
    String id,
    String name,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ProfileImage(
            id: name,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 90,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // PICKER
  // =========================

  Widget _modernPicker(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
