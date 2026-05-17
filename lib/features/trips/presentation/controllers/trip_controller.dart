import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/states/trip_state.dart';
import 'package:splittr/shared/services/trip_summary_calculator.dart';

class TripNotifier extends FamilyAsyncNotifier<TripScreenData, TripModel> {
  @override
  Future<TripScreenData> build(TripModel arg) async {
    return _computeData(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result =
        await ref.read(fetchTripUseCaseProvider).call(state.value!.trip.id);
    if (result.isFailure) {
      // Restore last-known good data on error rather than showing error screen
      state = AsyncData(state.value!);
      return;
    }
    // Re-read from Hive — the use case already cached it
    final fresh = HiveBoxes.trips.get(state.value!.trip.id);
    if (fresh != null) state = AsyncData(_computeData(fresh));
  }

  void applyExpenseAdded(ExpenseModel expense) {
    _mutateTrip((trip) => trip.copyWith(
          expenses: [...trip.expenses, expense],
        ));
  }

  void applyExpenseUpdated(ExpenseModel updated) {
    _mutateTrip((trip) => trip.copyWith(
          expenses: trip.expenses
              .map((e) => e.id == updated.id ? updated : e)
              .toList(),
        ));
  }

  void applyExpenseDeleted(String expenseId) {
    _mutateTrip((trip) => trip.copyWith(
          expenses: trip.expenses.where((e) => e.id != expenseId).toList(),
        ));
  }

  void applyPaymentChanged() {
    final fresh = HiveBoxes.trips.get(state.value!.trip.id);
    if (fresh != null) state = AsyncData(_computeData(fresh));
  }

  // ── private ───────────────────────────────────────────────────────────────

  void _mutateTrip(TripModel Function(TripModel) update) {
    final current = state.value;
    if (current == null) return;

    final updated = update(current.trip);

    final sortedExpenses = [...updated.expenses]
      ..sort((a, b) => b.created.compareTo(a.created));

    final sortedPayments = [...updated.payments]
      ..sort((a, b) => b.created.compareTo(a.created));

    final normalizedTrip = updated.copyWith(
      expenses: sortedExpenses,
      payments: sortedPayments,
    );

    HiveBoxes.trips.put(normalizedTrip.id, normalizedTrip);

    state = AsyncData(_computeData(normalizedTrip));
  }

  TripScreenData _computeData(TripModel trip) {
    final userId = ref.read(currentUserProvider)?.id ?? '';
    final summary = TripSummaryCalculator.calculate(trip: trip, userId: userId);
    return TripScreenData(trip: trip, summary: summary);
  }
}
