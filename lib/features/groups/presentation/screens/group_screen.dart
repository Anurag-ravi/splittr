// group_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/app_loader.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/screens/trip_screen.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final listAsync = ref.watch(groupsListProvider);

    final listNotifier = ref.read(groupsListProvider.notifier);

    final hideSettled = ref.watch(hideSettledProvider);

    return ValueListenableBuilder<Box<TripModel>>(
      valueListenable: HiveBoxes.trips.listenable(),
      builder: (context, _, __) {
        final user = HiveBoxes.me.get(AppConstants.hiveBoxMe);

        if (user == null) {
          return const AppLoader();
        }

        final visible = listNotifier.visibleTrips(
          hideSettled: hideSettled,
        );

        final summaries = listNotifier.netSummaries();

        return RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () async {
            await listNotifier.refresh();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  110,
                ),
                sliver: visible.isEmpty
                    ? SliverToBoxAdapter(
                        child: _emptyState(context),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final trip = visible[index];

                            final summary = summaries[trip.id]!;

                            final isOwed = summary.amount > 0;

                            final amount = summary.amount.abs();

                            final isSettled = summary.amount == 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: GestureDetector(
                                onTap: () {
                                  Haptics.medium();

                                  final full = HiveBoxes.trips.get(trip.id);

                                  if (full == null) return;

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TripScreen(
                                        id: trip.id,
                                        trip: full,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),

                                    // GLASS SURFACE
                                    color: colorScheme.surface.withOpacity(
                                      theme.brightness == Brightness.dark
                                          ? 0.88
                                          : 0.96,
                                    ),

                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(
                                        theme.brightness == Brightness.dark
                                            ? 0.12
                                            : 0.08,
                                      ),
                                    ),

                                    // NEON GLOW
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(
                                          theme.brightness == Brightness.dark
                                              ? 0.10
                                              : 0.04,
                                        ),
                                        blurRadius: 26,
                                        spreadRadius: -4,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          theme.brightness == Brightness.dark
                                              ? 0.14
                                              : 0.04,
                                        ),
                                        blurRadius: 22,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 88,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                colorScheme.primary
                                                    .withOpacity(0.20),
                                                colorScheme.primary
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: colorScheme.primary
                                                  .withOpacity(0.16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.primary
                                                    .withOpacity(0.14),
                                                blurRadius: 18,
                                                spreadRadius: -2,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.groups_rounded,
                                              size: 42,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trip.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              if (isSettled)
                                                Text(
                                                  'You are all settled up',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.textTheme
                                                        .bodyMedium?.color
                                                        ?.withOpacity(0.6),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  summary.message,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: isOwed
                                                        ? colorScheme.primary
                                                        : colorScheme.error,
                                                  ),
                                                ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: visible.length,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'No Groups Yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Create or join a group to start splitting expenses with friends.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
