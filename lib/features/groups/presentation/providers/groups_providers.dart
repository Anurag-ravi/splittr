import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/features/groups/presentation/controllers/groups_controller.dart';
import 'package:splittr/features/groups/presentation/states/groups_state.dart';

/// Loads and caches all trips. Auto-fetches on first watch.
final groupsListProvider =
    AsyncNotifierProvider<GroupsListNotifier, void>(GroupsListNotifier.new);

/// Handles create / join group mutations.
final groupMutationProvider =
    AsyncNotifierProvider<GroupMutationNotifier, GroupMutationSuccess?>(
        GroupMutationNotifier.new);

/// Persisted toggle for "hide settled groups".
final hideSettledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.prefKeyHideSettledGroups) ?? false;
});
