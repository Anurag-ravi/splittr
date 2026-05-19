import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/expenses/presentation/controllers/comments_controller.dart';
import 'package:splittr/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/expenses/presentation/states/comments_state.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/widgets/comment_tile.dart';

typedef AddExpenseBuilder = Widget Function(BuildContext context);

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

    _myUserId = HiveBoxes.me.get(AppConstants.hiveBoxMe)?.id;

    _buildNets();

    // VERY IMPORTANT:
    // clear previous expense action state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseNotifierProvider.notifier).reset();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentsProvider(widget.expense.id).notifier)
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
                  duration: const Duration(seconds: 4),
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
                      duration: Duration(seconds: 4),
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

    return 'Added on ${_months[d.month - 1]} ${d.day}, ${d.year} at '
        '${h.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')} '
        '$ampm';
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.expense.id));

    final commentsCtrl = ref.read(commentsProvider(widget.expense.id).notifier);

    final expenseAsync = ref.watch(expenseNotifierProvider);

    final expenseCtrl = ref.read(expenseNotifierProvider.notifier);

    final comments = commentsAsync.value ?? [];

    final sendingComment = commentsAsync.isLoading;

    final deleting = expenseAsync.isLoading;

    final expense = widget.expense;

    final totalRows = 3 + _nets.length + 1 + comments.length;

    return Stack(
      children: [
        Opacity(
          opacity: deleting ? 0.5 : 1,
          child: Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.pink[50],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(
                    context,
                    {
                      'changed': false,
                      'expense': expense,
                    },
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    Haptics.medium();

                    _confirmDelete(context, expenseCtrl);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    Haptics.medium();

                    final res = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => widget.addExpenseBuilder(ctx),
                      ),
                    );

                    if (res != null && res['changed'] == true && mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => commentsCtrl.refreshForExpense(expense.id),
                    child: ListView.builder(
                      itemCount: totalRows,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 50,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    'assets/categories/${expense.category}.png',
                                    height: 45,
                                    width: 45,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹ ${expense.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        if (i == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              _dateStr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }

                        if (i == 2) {
                          final firstPayer =
                              widget.tripUserMap[expense.paidBy[0].user];

                          return Padding(
                            padding: const EdgeInsets.only(top: 20, left: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: ProfileImage(
                                    id: firstPayer?.name ?? '1',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  expense.paidBy.length == 1
                                      ? '${firstPayer?.name ?? ''} paid ₹${expense.amount}'
                                      : '${expense.paidBy.length} people paid ₹${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (i < 3 + _nets.length) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 75, top: 10),
                            child: Text(
                              _nets[i - 3],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }

                        if (i == 3 + _nets.length) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Activity',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final comment = comments[i - 3 - _nets.length - 1];

                        return CommentTile(
                          comment: comment,
                          tripUserMap: widget.tripUserMap,
                          myUserId: _myUserId,
                          onDelete: () {
                            commentsCtrl.deleteFromExpense(
                              comment.id,
                              expense.id,
                            );
                          },
                        );
                      },
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
        if (deleting)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExpenseNotifier ctrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'This will permanently delete this expense.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ctrl.delete(widget.expense.id);
    }
  }

  Widget _commentInput(
    BuildContext context,
    CommentsNotifier ctrl,
    ExpenseModel expense,
    bool sending,
  ) {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _post(ctrl, expense),
            ),
          ),
          const SizedBox(width: 8),
          sending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () => _post(ctrl, expense),
                ),
        ],
      ),
    );
  }

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
}
