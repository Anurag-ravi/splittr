import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/activity/presentation/screens/activity_screen.dart';
import 'package:splittr/features/friends/presentation/screens/friends_screen.dart';
import 'package:splittr/features/groups/presentation/screens/create_group_screen.dart';
import 'package:splittr/features/groups/presentation/screens/group_screen.dart';
import 'package:splittr/features/groups/presentation/screens/join_group_screen.dart';
import 'package:splittr/features/profile/presentation/screens/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.initialIndex});

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
    _checkForNewRelease();
  }

  Future<void> _checkForNewRelease() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (!(prefs.getBool(AppConstants.prefKeyUpdate) ?? true)) return;

    const currentTag = String.fromEnvironment('TAG');
    try {
      final response = await http.get(
        Uri.parse(AppConstants.gitHubReleasesUrl),
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );
      if (!mounted || response.statusCode != 200) return;
      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return;
      final latest = data[0] as Map<String, dynamic>;
      if (latest['tag_name'] == currentTag) return;
      final downloadUrl =
          latest['assets'][0]['browser_download_url'] as String;
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New Update Available'),
          content: Text(
            'Your version: $currentTag\nLatest: ${latest['tag_name']}'
            '\n\nUpdate for the latest features and fixes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                prefs.setBool(AppConstants.prefKeyUpdate, false);
                Navigator.pop(context);
              },
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                prefs.setBool(AppConstants.prefKeyUpdate, false);
                Navigator.pop(context);
                launchUrl(Uri.parse(downloadUrl));
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    } catch (_) {}
  }

  void _changeTab(int index) {
    Haptics.medium();
    setState(() => _currentIndex = index);
  }

  String get _title =>
      const ['Groups', 'Friends', 'Activity', 'Profile'][_currentIndex];

  List<Widget> get _actions {
    if (_currentIndex != 0) return [];
    return [
      IconButton(
        icon: const Icon(Icons.add_box_outlined, color: Colors.white),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.group_add_outlined, color: Colors.white),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldDark,
        title: Text(_title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        actions: _actions,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.scaffoldDark,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            _navItem(Icons.group_outlined, 'Groups', 0),
            _navItem(Icons.person_outline, 'Friends', 1),
            _navItem(Icons.show_chart_outlined, 'Activity', 2),
            _profileNavItem(user?.dp),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
      IconData icon, String label, int index) {
    final selected = _currentIndex == index;
    return BottomNavigationBarItem(
      label: '',
      icon: GestureDetector(
        onTap: () => _changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : Colors.white),
            Text(label,
                style: TextStyle(
                    color: selected ? AppColors.primary : Colors.white)),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _profileNavItem(String? dp) {
    final selected = _currentIndex == 3;
    return BottomNavigationBarItem(
      label: '',
      icon: GestureDetector(
        onTap: () => _changeTab(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dp == null
                ? Icon(Icons.person_outline,
                    color: selected ? AppColors.primary : Colors.white)
                : ClipOval(
                    child: CircleAvatar(
                      backgroundColor: AppColors.scaffoldDark,
                      radius: 13,
                      backgroundImage: AssetImage('assets/profile/$dp.png'),
                    ),
                  ),
            Text('Account',
                style: TextStyle(
                    color: selected ? AppColors.primary : Colors.white)),
          ],
        ),
      ),
    );
  }
}
