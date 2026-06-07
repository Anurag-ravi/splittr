import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/controllers/comments_controller.dart';
import 'package:splittr/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/widgets/comment_tile.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

typedef AddExpenseBuilder = Widget Function(
  BuildContext context,
);

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({
    super.key,
    required this.expense,
    required this.trip,
    required this.tripUserMap,
    required this.addExpenseBuilder,
  });

  final ExpenseModel expense;

  final TripModel trip;

  final Map<String, TripMemberModel> tripUserMap;

  final AddExpenseBuilder addExpenseBuilder;

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
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

  List<String> _nets = [];

  String? _myUserId;

  @override
  void initState() {
    super.initState();

    _myUserId = HiveBoxes.me
        .get(
          AppConstants.hiveBoxMe,
        )
        ?.id;

    _buildNets();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseNotifierProvider.notifier).reset();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
            commentsProvider(widget.expense.id).notifier,
          )
          .refreshForExpense(widget.expense.id);
    });

    ref.listenManual<AsyncValue<ExpenseSavedData>>(
      expenseNotifierProvider,
      (_, next) {
        next.whenOrNull(
          error: (e, _) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          },
          data: (result) {
            if (!mounted) return;

            if (result.action == ExpenseAction.deleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && Navigator.canPop(context)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  Navigator.pop(
                    context,
                    {
                      'changed': true,
                      'expense': null,
                    },
                  );
                }
              });
            } else if (result.action == ExpenseAction.saved) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(
                    context,
                    {
                      'changed': true,
                      'expense': result.expense,
                    },
                  );
                }
              });
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  void _buildNets() {
    final paid = <TripMemberModel, double>{};

    final owed = <TripMemberModel, double>{};

    for (final x in widget.expense.paidBy) {
      final tu = widget.tripUserMap[x.user];

      if (tu != null) {
        paid[tu] = x.amount;
      }
    }

    for (final x in widget.expense.paidFor) {
      final tu = widget.tripUserMap[x.user];

      if (tu != null) {
        owed[tu] = x.amount;
      }
    }

    final t1 = <String>[];

    final t2 = <String>[];

    for (final entry in widget.tripUserMap.entries) {
      final tu = entry.value;

      final hasPaid = paid.containsKey(tu);

      final hasOwed = owed.containsKey(tu);

      if (!hasPaid && !hasOwed) continue;

      var line = tu.name.trim();

      if (hasPaid) {
        line += ' paid ₹${paid[tu]!.toStringAsFixed(2)}';
      }

      if (hasOwed) {
        if (hasPaid) {
          line += ' and';
        }

        line += ' owed ₹${owed[tu]!.toStringAsFixed(2)}';
      }

      (hasPaid ? t1 : t2).add(line);
    }

    _nets = [...t1, ...t2];
  }

  String _dateStr() {
    final d = widget.expense.created;

    int h = d.hour;

    final ampm = h >= 12 ? 'PM' : 'AM';

    if (h > 12) h -= 12;

    if (h == 0) h = 12;

    return '${_months[d.month - 1]} ${d.day}, ${d.year} • '
        '${h.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')} '
        '$ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final commentsAsync = ref.watch(
      commentsProvider(widget.expense.id),
    );

    final commentsCtrl = ref.read(
      commentsProvider(widget.expense.id).notifier,
    );

    final expenseAsync = ref.watch(
      expenseNotifierProvider,
    );

    final expenseCtrl = ref.read(
      expenseNotifierProvider.notifier,
    );

    final comments = commentsAsync.value ?? [];

    final sendingComment = commentsAsync.isLoading;

    final deleting = expenseAsync.isLoading;

    final expense = widget.expense;

    final totalPaid = expense.amount;

    return Stack(
      children: [
        Opacity(
          opacity: deleting ? 0.5 : 1,
          child: Scaffold(
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
                          onTap: () {
                            Navigator.pop(
                              context,
                              {
                                'changed': false,
                                'expense': expense,
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            'Expense',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _topActionButton(
                          context,
                          icon: Icons.delete_outline_rounded,
                          iconColor: colorScheme.error,
                          onTap: () {
                            Haptics.medium();

                            _confirmDelete(
                              context,
                              expenseCtrl,
                            );
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _topActionButton(
                          context,
                          icon: Icons.edit_outlined,
                          onTap: () async {
                            Haptics.medium();

                            final res =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => widget.addExpenseBuilder(
                                  ctx,
                                ),
                              ),
                            );

                            if (res != null &&
                                res['changed'] == true &&
                                mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      color: colorScheme.primary,
                      onRefresh: () => commentsCtrl.refreshForExpense(
                        expense.id,
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          8,
                          10,
                          120,
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: colorScheme.surface.withOpacity(
                                theme.brightness == Brightness.dark
                                    ? 0.92
                                    : 0.97,
                              ),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(
                                  0.10,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(
                                    0.08,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: -8,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // =========================
                                // TOP ROW
                                // =========================

                                Row(
                                  children: [
                                    // CATEGORY

                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorScheme.primary.withOpacity(
                                              0.18,
                                            ),
                                            colorScheme.primary.withOpacity(
                                              0.05,
                                            ),
                                          ],
                                        ),
                                        border: Border.all(
                                          color:
                                              colorScheme.primary.withOpacity(
                                            0.10,
                                          ),
                                        ),
                                      ),
                                      child: CategoryIcon(
                                        category: expense.category,
                                        entityType: 'expense',
                                        size: 60,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // TITLE

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _dateStr(),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.textTheme
                                                      .bodyMedium?.color
                                                      ?.withOpacity(
                                                    0.66,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '₹${expense.amount.toStringAsFixed(2)}',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Split details',
                                  style: theme.textTheme.titleMedium,
                                ),

                                const SizedBox(height: 10),

                                // =========================
                                // SPLIT DETAILS
                                // =========================

                                Column(
                                  children: [
                                    ..._nets.asMap().entries.map(
                                      (entry) {
                                        final i = entry.key;

                                        final text = entry.value;

                                        // FIND USER

                                        final matchingUser = widget
                                            .tripUserMap.values
                                            .firstWhere(
                                          (u) => text.startsWith(
                                            u.name.trim(),
                                          ),
                                        );

                                        final isPaid = text.contains(
                                          'paid',
                                        );

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                i == _nets.length - 1 ? 0 : 10,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                22,
                                              ),
                                              color: colorScheme.surface
                                                  .withOpacity(
                                                0.68,
                                              ),
                                              border: Border.all(
                                                color: (isPaid
                                                        ? colorScheme.primary
                                                        : AppColors.amber)
                                                    .withOpacity(
                                                  0.08,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // PROFILE

                                                Container(
                                                  width: 54,
                                                  height: 54,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      18,
                                                    ),
                                                  ),
                                                  child: ProfileImage(
                                                    id: matchingUser.name,
                                                  ),
                                                ),

                                                const SizedBox(
                                                  width: 14,
                                                ),

                                                // TEXT

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        matchingUser.name,
                                                        style: theme.textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                        text.replaceFirst(
                                                          '${matchingUser.name.trim()} ',
                                                          '',
                                                        ),
                                                        style: theme.textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          height: 1.5,
                                                          color: theme.textTheme
                                                              .bodyMedium?.color
                                                              ?.withOpacity(
                                                            0.72,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

// =========================
// ACTIVITY
// =========================

                          Row(
                            children: [
                              Text(
                                'Activity',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(
                                    0.68,
                                  ),
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
// EMPTY COMMENTS
// =========================

                          if (comments.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  24,
                                ),
                                color: colorScheme.surface.withOpacity(0.72),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.06),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 32,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No activity yet',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Start the conversation by adding a comment.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(
                                        0.68,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ...comments.map(
                            (comment) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: CommentTile(
                                comment: comment,
                                tripUserMap: widget.tripUserMap,
                                myUserId: _myUserId,
                                onDelete: () {
                                  commentsCtrl.deleteFromExpense(
                                    comment.id,
                                    expense.id,
                                  );
                                },
                              ),
                            ),
                          ),

// =========================
// END REPLACEMENT
// =========================
                        ],
                      ),
                    ),
                  ),

                  _commentInput(
                    context,
                    commentsCtrl,
                    expense,
                    sendingComment,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (deleting)
          Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          ),
      ],
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<void> _confirmDelete(
    BuildContext context,
    ExpenseNotifier ctrl,
  ) async {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  24,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(
                    0.96,
                  ),
                  borderRadius: BorderRadius.circular(
                    30,
                  ),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Delete expense?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.68,
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(
                      height: 26,
                    ),
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
                            child: const Text(
                              'Cancel',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
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
                            child: const Text(
                              'Delete',
                            ),
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

    if (confirmed == true && mounted) {
      ctrl.delete(
        widget.expense.id,
      );
    }
  }

  // =========================
  // COMMENT INPUT
  // =========================

  Widget _commentInput(
    BuildContext context,
    CommentsNotifier ctrl,
    ExpenseModel expense,
    bool sending,
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
        color: colorScheme.surface.withOpacity(0.94),
        border: Border(
          top: BorderSide(
            color: colorScheme.primary.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  22,
                ),
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
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(
                      0.42,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _post(
                  ctrl,
                  expense,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
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
                    expense,
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
  // POST
  // =========================

  void _post(
    CommentsNotifier ctrl,
    ExpenseModel expense,
  ) {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    _commentController.clear();

    ctrl.postOnExpense(
      text: text,
      expenseId: expense.id,
      tripId: expense.trip,
      expenseName: expense.name,
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // =========================
  // PERSON CARD
  // =========================

  Widget _personAmountCard(
    BuildContext context, {
    required String name,
    required double amount,
    required String subtitle,
    required String profileId,
    required Color color,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          24,
        ),
        color: colorScheme.surface.withOpacity(0.72),
        border: Border.all(
          color: color.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                22,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(
                    0.18,
                  ),
                  color.withOpacity(
                    0.05,
                  ),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(
                  0.10,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                7,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  18,
                ),
                child: ProfileImage(
                  id: profileId,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(
                      0.66,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
