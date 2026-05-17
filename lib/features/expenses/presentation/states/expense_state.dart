import 'package:splittr/features/expenses/data/models/expense_model.dart';

enum ExpenseAction {
  idle,
  saved,
  deleted,
}

final class ExpenseSavedData {
  final ExpenseModel? expense;
  final bool isNew;
  final ExpenseAction action;

  const ExpenseSavedData({
    required this.expense,
    required this.isNew,
    required this.action,
  });

  factory ExpenseSavedData.idle() {
    return const ExpenseSavedData(
      expense: null,
      isNew: false,
      action: ExpenseAction.idle,
    );
  }

  factory ExpenseSavedData.deleted() {
    return const ExpenseSavedData(
      expense: null,
      isNew: false,
      action: ExpenseAction.deleted,
    );
  }

  factory ExpenseSavedData.saved({
    required ExpenseModel expense,
    required bool isNew,
  }) {
    return ExpenseSavedData(
      expense: expense,
      isNew: isNew,
      action: ExpenseAction.saved,
    );
  }
}
