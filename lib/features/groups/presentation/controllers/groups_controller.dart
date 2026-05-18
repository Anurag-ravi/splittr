import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/groups/presentation/states/groups_state.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_net_summary.dart';
import 'package:splittr/shared/services/trip_net_calculator.dart';

/// Fetches and caches all trips. State = AsyncValue<void> (loading/error/done).
class GroupsListNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() => _fetch();

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    state = const AsyncLoading();

    final result = await ref
        .read(
          fetchAllTripsUseCaseProvider,
        )
        .call();

    state = result.when(
      success: (_) {
        // =========================
        // CLEAN INVALID SHORT TRIPS
        // =========================

        final validIds = HiveBoxes.trips.keys.map((e) => e.toString()).toSet();

        final invalidTrips = HiveBoxes.shortTrips.values
            .where(
              (s) => !validIds.contains(s.id),
            )
            .toList();

        for (final trip in invalidTrips) {
          HiveBoxes.shortTrips.delete(trip.id);
        }

        return const AsyncData(null);
      },
      onFailure: (f) => AsyncError(
        f.message,
        StackTrace.current,
      ),
    );
  }

  // ── Pure helpers (read Hive, no mutations) ────────────────────────────────

  List<ShortTripModel> visibleTrips({
    required bool hideSettled,
  }) {
    final user = ref.read(currentUserProvider);

    if (user == null) return [];

    final trips = HiveBoxes.trips.values.toList()
      ..sort(
        (a, b) => b.created.compareTo(a.created),
      );

    final tripMap = {
      for (final t in trips) t.id: t,
    };

    // FILTER INVALID SHORT TRIPS FIRST

    final validShortTrips = HiveBoxes.shortTrips.values
        .where((s) => tripMap.containsKey(s.id))
        .toList()
      ..sort((a, b) {
        final tripA = tripMap[a.id];
        final tripB = tripMap[b.id];

        if (tripA == null || tripB == null) {
          return 0;
        }

        return tripB.created.compareTo(
          tripA.created,
        );
      });

    return validShortTrips.where((s) {
      final t = tripMap[s.id];

      if (t == null) return false;

      if (hideSettled) {
        final summary = TripNetCalculator.calculate(
          trip: t,
          currentUserId: user.id,
        );

        if (summary.settled) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Map<String, TripNetSummary> netSummaries() {
    final user = ref.read(currentUserProvider);
    if (user == null) return {};
    return {
      for (final t in HiveBoxes.trips.values)
        t.id: TripNetCalculator.calculate(trip: t, currentUserId: user.id),
    };
  }
}

/// Handles create / join mutations. State = AsyncValue<GroupMutationSuccess?>.
class GroupMutationNotifier extends AsyncNotifier<GroupMutationSuccess?> {
  @override
  Future<GroupMutationSuccess?> build() async => null;

  Future<void> createGroup(String name) async {
    state = const AsyncLoading();
    final result = await ref.read(createTripUseCaseProvider).call(name);
    state = result.when(
      success: (_) => const AsyncData(GroupMutationSuccess('Group Created')),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
    if (state.hasValue) {
      // Invalidate the list notifier so it re-fetches automatically.
      ref.invalidate(groupsListProvider);
    }
  }

  Future<void> joinGroup(String code) async {
    state = const AsyncLoading();
    final result = await ref.read(joinTripUseCaseProvider).call(code);
    state = result.when(
      success: (_) => const AsyncData(GroupMutationSuccess('Joined Group')),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
    if (state.hasValue) {
      ref.invalidate(groupsListProvider);
    }
  }

  void reset() => state = const AsyncData(null);
}
