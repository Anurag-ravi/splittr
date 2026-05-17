import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/app_loader.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/groups/presentation/screens/create_group_screen.dart';
import 'package:splittr/features/groups/presentation/screens/join_group_screen.dart';
import 'package:splittr/features/groups/presentation/widgets/group_card.dart';
import 'package:splittr/features/trips/presentation/screens/trip_screen.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<void>>(groupsListProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          if (!mounted) return;
          final listNotifier = ref.read(groupsListProvider.notifier);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    Haptics.medium();
                    listNotifier.refresh();
                  },
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(groupsListProvider);
    final listNotifier = ref.read(groupsListProvider.notifier);
    final hideSettled = ref.watch(hideSettledProvider);

    final isLoading = listAsync.isLoading;

    return ValueListenableBuilder<Box<TripModel>>(
      valueListenable: HiveBoxes.trips.listenable(),
      builder: (context, _, __) {
        final user = HiveBoxes.me.get('me');
        if (user == null) return const AppLoader();

        final visible = listNotifier.visibleTrips(hideSettled: hideSettled);
        final summaries = listNotifier.netSummaries();

        return RefreshIndicator(
          onRefresh: () => listNotifier.refresh(),
          child: visible.isEmpty
              ? _emptyState(context, isLoading)
              : ListView.builder(
                  itemCount: visible.length + 1 + (isLoading ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx == 0) return _toggleRow(context, ref, hideSettled);
                    if (isLoading && idx == 1) return const ApiLoader();
                    final trip = visible[idx - 1 - (isLoading ? 1 : 0)];
                    return GroupCard(
                      trip: trip,
                      summary: summaries[trip.id]!,
                      onTap: () {
                        Haptics.medium();
                        final full = HiveBoxes.trips.get(trip.id);
                        if (full == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Trip data not available'),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TripScreen(id: trip.id, trip: full),
                        ));
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _toggleRow(BuildContext context, WidgetRef ref, bool hideSettled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Hide Settled Up Groups',
            style: TextStyle(color: Colors.grey[100])),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          height: 30,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch(
              value: hideSettled,
              activeColor: AppColors.primary,
              onChanged: (v) {
                Haptics.medium();
                ref.read(hideSettledProvider.notifier).state = v;
                ref
                    .read(sharedPreferencesProvider)
                    .setBool(AppConstants.prefKeyHideSettledGroups, v);
              },
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _emptyState(BuildContext context, bool loading) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      children: [
        const SizedBox(height: 150),
        if (loading) const ApiLoader(),
        Center(
          child: Text(
            'You are not involved in any groups',
            style: TextStyle(color: Colors.grey[100]),
          ),
        ),
        const SizedBox(height: 10),
        _actionButton('Create Group', AppColors.primary, () {
          Haptics.medium();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
        }),
        const SizedBox(height: 10),
        Center(child: Text('OR', style: TextStyle(color: Colors.grey[100]))),
        const SizedBox(height: 10),
        _actionButton('Join Group', AppColors.amber, () {
          Haptics.medium();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const JoinGroupScreen()));
        }),
      ],
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
