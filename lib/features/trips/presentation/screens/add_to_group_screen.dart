// add_to_group_screen.dart

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/screens/add_new_contact_screen.dart';

class AddToGroupScreen extends StatefulWidget {
  const AddToGroupScreen({
    super.key,
    required this.trip,
  });

  final TripModel trip;

  @override
  State<AddToGroupScreen> createState() => _AddToGroupScreenState();
}

class _AddToGroupScreenState extends State<AddToGroupScreen> {
  List<UserModel> _friends = [];

  List<bool> _selected = [];

  Set<String> _involvedUsers = {};

  bool _loading = false;

  bool _apiFetching = false;

  bool get _hasSelection => _selected.contains(true);

  @override
  void initState() {
    super.initState();

    _involvedUsers =
        widget.trip.users.where((u) => u.involved).map((u) => u.user).toSet();

    _friends = HiveBoxes.users.values.toList();

    _selected = List<bool>.filled(
      _friends.length,
      false,
    );
  }

  Future<void> _refreshFriends() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();

    final numbersJson = prefs.getString(
      AppConstants.prefKeyNumbers,
    );

    if (numbersJson == null) {
      setState(() => _loading = false);
      return;
    }

    final numbers = List<String>.from(
      jsonDecode(numbersJson) as List,
    );

    if (!mounted) return;

    final data = await AppHttpClient.post(
      context,
      '/auth/get-friends',
      {
        'contacts': numbers,
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (data != null && data['status'] == 200) {
      final temp = List<UserModel>.from(
        (data['friends'] as List).map((u) => UserModel.fromJson(u)),
      );

      final box = HiveBoxes.users;

      for (final u in box.values.toList()) {
        if (!temp.any((t) => t.id == u.id)) {
          box.delete(u.id);
        }
      }

      for (final u in temp) {
        await box.put(u.id, u);
      }

      setState(() {
        _friends = temp;

        _selected = List<bool>.filled(
          _friends.length,
          false,
        );
      });

      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data?['message']?.toString() ?? 'Error',
        ),
      ),
    );
  }

  Future<void> _addToGroup() async {
    setState(() => _apiFetching = true);

    final selectedUsers = <String>[
      for (int i = 0; i < _selected.length; i++)
        if (_selected[i]) _friends[i].id,
    ];

    if (!mounted) return;

    final data = await AppHttpClient.post(
      context,
      '/trip/${widget.trip.id}/add-many',
      {
        'users': selectedUsers,
      },
    );

    if (!mounted) return;

    setState(() => _apiFetching = false);

    if (data != null && data['status'] == 200) {
      final modified = List<TripMemberModel>.from(
        (data['data'] as List).map((x) => TripMemberModel.fromJson(x)),
      );

      final updated = widget.trip.copyWith(
        users: modified,
      );

      await HiveBoxes.trips.put(
        widget.trip.id,
        updated,
      );

      if (!mounted) return;

      Navigator.pop(context);

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data?['message']?.toString() ?? 'Error',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Add People',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        actions: [
          if (_hasSelection)
            Padding(
              padding: const EdgeInsets.only(
                right: 14,
              ),
              child: _apiFetching
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Haptics.medium();

                        _addToGroup();
                      },
                      child: Center(
                        child: Text(
                          'Done',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: 24,
        ),
        itemCount: _friends.length + 3,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: GestureDetector(
                onTap: () async {
                  Haptics.medium();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddNewContactScreen(
                        tripId: widget.trip.id,
                        trip: widget.trip,
                      ),
                    ),
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: colorScheme.surface.withOpacity(0.90),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: colorScheme.primary.withOpacity(0.12),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Add new contact to Splittr',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (idx == 1) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 2,
                bottom: 12,
              ),
              child: Text(
                'Friends on Splittr',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                ),
              ),
            );
          }

          if (idx == _friends.length + 2) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Haptics.medium();

                    _refreshFriends();
                  },
                  child: _loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Text(
                          'Refresh Friends',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            );
          }

          final index = idx - 2;

          final friend = _friends[index];

          final alreadyIn = _involvedUsers.contains(friend.id);

          return GestureDetector(
            onTap: () {
              if (alreadyIn) return;

              Haptics.medium();

              setState(() {
                _selected[index] = !_selected[index];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: _selected[index]
                    ? colorScheme.primary.withOpacity(0.08)
                    : colorScheme.surface.withOpacity(0.88),
                border: Border.all(
                  color: _selected[index]
                      ? colorScheme.primary.withOpacity(0.28)
                      : colorScheme.primary.withOpacity(0.05),
                ),
              ),
              child: Opacity(
                opacity: alreadyIn ? 0.35 : 1,
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: ProfileImage(
                          id: friend.name,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (alreadyIn)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 2,
                              ),
                              child: Text(
                                'Already in group',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.55),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _selected[index] ? 1 : 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
