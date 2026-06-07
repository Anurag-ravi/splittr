import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/expenses/presentation/controllers/comments_controller.dart';
import 'package:splittr/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';

final expenseNotifierProvider =
    AsyncNotifierProvider<ExpenseNotifier, ExpenseSavedData>(
  ExpenseNotifier.new,
);

/// Keyed by entity ID (expense or payment).
final commentsProvider =
    AsyncNotifierProviderFamily<CommentsNotifier, List<CommentModel>, String>(
        CommentsNotifier.new);
