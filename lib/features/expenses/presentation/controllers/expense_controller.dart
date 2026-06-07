import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart'
    show SplitEntryModel;
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class ExpenseNotifier extends AsyncNotifier<ExpenseSavedData> {
  @override
  Future<ExpenseSavedData> build() async {
    return ExpenseSavedData.idle();
  }

  Future<void> save({
    required TripModel trip,
    required String name,
    required double amount,
    required String category,
    required splitTypeEnum splitType,
    required List<By> paidBy,
    required List<By> paidFor,
    required DateTime created,
    String? expenseId,
  }) async {
    state = const AsyncLoading();

    final adjustedBy = _adjustSinglePayer(paidBy, amount);
    final adjustedFor = _adjustSplit(splitType, paidFor, amount);

    final totalBy = adjustedBy.fold(0.0, (s, b) => s + b.amount);
    final totalFor = adjustedFor.fold(0.0, (s, b) => s + b.amount);

    if (totalBy.toStringAsFixed(2) != amount.toStringAsFixed(2) ||
        totalFor.toStringAsFixed(2) != amount.toStringAsFixed(2)) {
      state = AsyncError(
        'The split does not add up to the amount. Please check again.',
        StackTrace.current,
      );
      return;
    }

    final paidByEntities = adjustedBy
        .map(
          (b) => SplitEntryEntity(
            memberId: b.user,
            amount: b.amount,
            shareOrPercent: b.share_or_percent,
          ),
        )
        .toList();

    final paidForEntities = adjustedFor
        .map(
          (b) => SplitEntryEntity(
            memberId: b.user,
            amount: b.amount,
            shareOrPercent: b.share_or_percent,
          ),
        )
        .toList();

    final result = await ref.read(saveExpenseUseCaseProvider).call(
          tripId: trip.id,
          name: name,
          amount: amount,
          category: category,
          splitType: _toSplitType(splitType),
          paidBy: paidByEntities,
          paidFor: paidForEntities,
          created: created,
          expenseId: expenseId,
        );

    state = result.when(
      success: (entity) {
        final model = ExpenseModel(
          id: entity.id,
          trip: entity.tripId,
          name: entity.name,
          amount: entity.amount,
          category: entity.category,
          splitType: entity.splitType.name,
          created: entity.created,
          paidBy: entity.paidBy
              .map(
                (e) => SplitEntryModel(
                  user: e.memberId,
                  amount: e.amount,
                  shareOrPercent: e.shareOrPercent,
                ),
              )
              .toList(),
          paidFor: entity.paidFor
              .map(
                (e) => SplitEntryModel(
                  user: e.memberId,
                  amount: e.amount,
                  shareOrPercent: e.shareOrPercent,
                ),
              )
              .toList(),
        );

        return AsyncData(
          ExpenseSavedData.saved(
            expense: model,
            isNew: expenseId == null,
          ),
        );
      },
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> delete(String expenseId) async {
    state = const AsyncLoading();

    final result = await ref.read(deleteExpenseUseCaseProvider).call(expenseId);

    state = result.when(
      success: (_) => AsyncData(
        ExpenseSavedData.deleted(),
      ),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  List<By> _adjustSinglePayer(List<By> paidBy, double amount) {
    if (paidBy.length != 1) return paidBy;
    return [By(paidBy[0].user, amount, 0)];
  }

  List<By> _adjustSplit(
    splitTypeEnum type,
    List<By> paidFor,
    double amount,
  ) {
    if (type == SplitType.equal) {
      final n = paidFor.length;
      final per = AmountFormatter.round2(amount / n);

      final adjusted =
          paidFor.map((b) => By(b.user, per, b.share_or_percent)).toList();

      double diff = AmountFormatter.round2(amount - per * n);

      int i = 0;

      while (AmountFormatter.round2(diff) > 0.0) {
        adjusted[i % n].amount =
            AmountFormatter.round2(adjusted[i % n].amount + 0.01);

        i++;

        diff = AmountFormatter.round2(diff - 0.01);
      }

      return adjusted;
    }

    if (type == SplitType.shares) {
      final total = paidFor.fold(0, (s, b) => s + b.share_or_percent.toInt());

      if (total == 0) return paidFor;

      final adjusted = paidFor.map((b) {
        final a = AmountFormatter.round2(
          AmountFormatter.roundPrecise(
            amount * b.share_or_percent / total,
          ),
        );

        return By(b.user, a, b.share_or_percent);
      }).toList();

      double sum =
          adjusted.fold(0.0, (s, b) => AmountFormatter.round2(s + b.amount));

      double diff = AmountFormatter.round2(amount - sum);

      int i = 0;

      while (AmountFormatter.round2(diff) > 0.0) {
        adjusted[i % adjusted.length].amount = AmountFormatter.round2(
          adjusted[i % adjusted.length].amount + 0.01,
        );

        i++;

        diff = AmountFormatter.round2(diff - 0.01);
      }

      return adjusted;
    }

    return paidFor;
  }

  void reset() {
    state = const AsyncData(
      ExpenseSavedData(
        expense: null,
        isNew: false,
        action: ExpenseAction.idle,
      ),
    );
  }

  SplitType _toSplitType(splitTypeEnum e) => e;
}
