// home_screen.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/activity/presentation/screens/activity_screen.dart';
import 'package:splittr/features/friends/presentation/screens/friends_screen.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/groups/presentation/screens/create_group_screen.dart';
import 'package:splittr/features/groups/presentation/screens/group_screen.dart';
import 'package:splittr/features/groups/presentation/screens/join_group_screen.dart';
import 'package:splittr/features/profile/presentation/screens/profile_screen.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.initialIndex,
  });

  final int initialIndex;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    GroupScreen(),
    FriendsScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
  }

  void _changeTab(int index) {
    Haptics.medium();

    setState(() {
      _currentIndex = index;
    });
  }

  String get _title => const [
        'Groups',
        'Friends',
        'Activity',
        'Profile',
      ][_currentIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = ref.watch(currentUserProvider);

    final hasGroups = HiveBoxes.trips.values.isNotEmpty;

    final hideSettled = ref.watch(hideSettledProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 22,
        title: Text(
          _title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: _currentIndex == 0 && hasGroups
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _topActionButton(
                    icon: Icons.group_add_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const JoinGroupScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PopupMenuButton<String>(
                    tooltip: '',
                    color: colorScheme.surface,
                    elevation: 12,
                    offset: const Offset(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onSelected: (value) async {
                      if (value == 'hide_settled') {
                        final next = !hideSettled;

                        ref.read(hideSettledProvider.notifier).state = next;

                        await ref.read(sharedPreferencesProvider).setBool(
                              AppConstants.prefKeyHideSettledGroups,
                              next,
                            );
                      }
                    },
                    itemBuilder: (_) => [
                      CheckedPopupMenuItem<String>(
                        value: 'hide_settled',
                        checked: hideSettled,
                        child: const Text(
                          'Hide settled groups',
                        ),
                      ),
                    ],

                    // IMPORTANT FIX
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.dividerTheme.color ?? Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),
        height: 82,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.18 : 0.04,
              ),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context,
              icon: Icons.groups_rounded,
              label: 'Groups',
              index: 0,
            ),
            _navItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Friends',
              index: 1,
            ),
            NeonGlow(
              color: colorScheme.primary,
              radius: 34,
              spread: 6,
              glowOpacity: 0.22,
              child: GestureDetector(
                onTap: () {
                  Haptics.medium();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateGroupScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 34,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            _navItem(
              context,
              icon: Icons.show_chart_rounded,
              label: 'Activity',
              index: 2,
            ),
            _profileNavItem(
              context,
              user?.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _changeTab(index),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected
                  ? colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileNavItem(
    BuildContext context,
    String? dp,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selected = _currentIndex == 3;

    return GestureDetector(
      onTap: () => _changeTab(3),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dp == null
                ? Icon(
                    Icons.person_outline_rounded,
                    size: 28,
                    color: selected
                        ? colorScheme.primary
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: selected
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: selected
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 2.5,
                            )
                          : null,
                    ),
                    child: ProfileImage(
                      id: dp,
                      size: 25,
                    ),
                  ),
            const SizedBox(height: 6),
            Text(
              'Account',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Haptics.medium();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
