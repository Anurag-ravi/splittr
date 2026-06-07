import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/features/expenses/presentation/controllers/comments_controller.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/payments/presentation/controllers/payment_controller.dart';
import 'package:splittr/features/payments/presentation/providers/payment_providers.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/widgets/comment_tile.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

typedef PaymentPageBuilder = Widget Function(BuildContext context);

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.payment,
    required this.tripUserMap,
    required this.paymentPageBuilder,
  });

  final PaymentModel payment;

  final Map<String, TripMemberModel> tripUserMap;

  final PaymentPageBuilder paymentPageBuilder;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
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

  final _commentController = TextEditingController();

  String? _myUserId;

  @override
  void initState() {
    super.initState();

    _myUserId = HiveBoxes.me
        .get(
          AppConstants.hiveBoxMe,
        )
        ?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentsProvider(widget.payment.id).notifier)
          .refreshForPayment(widget.payment.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  String _dateStr() {
    final d = widget.payment.created;

    int h = d.hour;

    final ampm = h >= 12 ? 'PM' : 'AM';

    if (h > 12) h -= 12;

    if (h == 0) h = 12;

    return '${_months[d.month - 1]} ${d.day}, ${d.year} • '
        '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final commentsAsync = ref.watch(
      commentsProvider(widget.payment.id),
    );

    final commentsCtrl = ref.read(
      commentsProvider(widget.payment.id).notifier,
    );

    final paymentAsync = ref.watch(
      paymentNotifierProvider,
    );

    final paymentCtrl = ref.read(
      paymentNotifierProvider.notifier,
    );

    final comments = commentsAsync.value ?? [];

    final sending = commentsAsync.isLoading;

    final deleting = paymentAsync.isLoading;

    final p = widget.payment;

    final byName = widget.tripUserMap[p.by]?.name ?? '';

    final toName = widget.tripUserMap[p.to]?.name ?? '';

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
                    onTap: () => Navigator.pop(
                      context,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Payment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (deleting)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    _topActionButton(
                      context,
                      icon: Icons.delete_outline_rounded,
                      iconColor: colorScheme.error,
                      onTap: () {
                        Haptics.medium();

                        _confirmDelete(
                          context,
                          paymentCtrl,
                        );
                      },
                    ),
                  const SizedBox(width: 10),
                  _topActionButton(
                    context,
                    icon: Icons.edit_outlined,
                    onTap: () async {
                      Haptics.medium();

                      final res = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => widget.paymentPageBuilder(ctx),
                        ),
                      );

                      if (!mounted) return;

                      if (res == true) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: colorScheme.primary,
                onRefresh: () => commentsCtrl.refreshForPayment(
                  p.id,
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    8,
                    18,
                    120,
                  ),
                  children: [
                    // =========================
                    // PAYMENT CARD
                    // =========================

                    NeonGlow(
                      color: colorScheme.primary,
                      radius: 32,
                      spread: -10,
                      glowOpacity: 0.16,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            30,
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
                              blurRadius: 32,
                              spreadRadius: -8,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  28,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary.withOpacity(
                                      0.20,
                                    ),
                                    colorScheme.primary.withOpacity(
                                      0.05,
                                    ),
                                  ],
                                ),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(
                                    0.14,
                                  ),
                                ),
                              ),
                              child: const CategoryIcon(
                                category: 'payment',
                                entityType: 'payment',
                                size: 80,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              '$byName paid $toName',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '₹${p.amount.toStringAsFixed(2)}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                color: colorScheme.primary.withOpacity(
                                  0.08,
                                ),
                              ),
                              child: Text(
                                _dateStr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.72),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // ACTIVITY HEADER
                    // =========================

                    Row(
                      children: [
                        Text(
                          'Activity',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.68),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Divider(
                            color: colorScheme.outline.withOpacity(
                              0.16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // COMMENTS
                    // =========================

                    if (comments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: colorScheme.surface.withOpacity(
                            0.72,
                          ),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(
                              0.06,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 34,
                              color: colorScheme.primary.withOpacity(
                                0.7,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No activity yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Start the conversation by adding a comment.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.68),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ...comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CommentTile(
                          comment: c,
                          tripUserMap: widget.tripUserMap,
                          myUserId: _myUserId,
                          onDelete: () => commentsCtrl.deleteFromPayment(
                            c.id,
                            p.id,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // COMMENT INPUT
            // =========================

            _commentInput(
              context,
              commentsCtrl,
              sending,
              byName,
              toName,
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> _confirmDelete(
    BuildContext context,
    PaymentNotifier ctrl,
  ) async {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(
                    0.96,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(
                      0.10,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.error.withOpacity(
                          0.10,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 36,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Delete payment?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.68),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ctrl.delete(
        widget.payment.id,
        widget.payment.trip,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment deleted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.surface,
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================
  // COMMENT INPUT
  // =========================

  Widget _commentInput(
    BuildContext context,
    CommentsNotifier ctrl,
    bool sending,
    String byName,
    String toName,
  ) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(
          0.94,
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.primary.withOpacity(
              0.08,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: colorScheme.surface.withOpacity(
                  0.72,
                ),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(
                    0.06,
                  ),
                ),
              ),
              child: TextField(
                controller: _commentController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.42),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _post(
                  ctrl,
                  byName,
                  toName,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          sending
              ? SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorScheme.primary,
                  ),
                )
              : GestureDetector(
                  onTap: () => _post(
                    ctrl,
                    byName,
                    toName,
                  ),
                  child: NeonGlow(
                    color: colorScheme.primary,
                    radius: 18,
                    spread: -2,
                    glowOpacity: 0.16,
                    child: Container(
                      width: 52,
                      height: 52,
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
                        Icons.send_rounded,
                        color: colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // =========================
  // POST COMMENT
  // =========================

  void _post(
    CommentsNotifier ctrl,
    String byName,
    String toName,
  ) {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    _commentController.clear();

    final p = widget.payment;

    ctrl.postOnPayment(
      text: text,
      paymentId: p.id,
      tripId: p.trip,
      title:
          'Comment added on payment of ₹${p.amount.toStringAsFixed(2)} from $byName to $toName',
    );
  }

  // =========================
  // TOP ACTION BUTTON
  // =========================

  Widget _topActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
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
              size: 22,
              color: iconColor ?? colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
