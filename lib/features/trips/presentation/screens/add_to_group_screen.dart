import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/trips/presentation/screens/add_new_contact_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class AddToGroupScreen extends StatefulWidget {
  const AddToGroupScreen({super.key, required this.trip});

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
    _selected = List<bool>.filled(_friends.length, false);
  }

  Future<void> _refreshFriends() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final numbersJson = prefs.getString(AppConstants.prefKeyNumbers);
    if (numbersJson == null) {
      setState(() => _loading = false);
      return;
    }
    final numbers = List<String>.from(jsonDecode(numbersJson) as List);

    if (!mounted) return;
    final data = await AppHttpClient.post(
        context, '/auth/get-friends', {'contacts': numbers});
    if (!mounted) return;
    setState(() => _loading = false);

    if (data != null && data['status'] == 200) {
      final temp = List<UserModel>.from(
          (data['friends'] as List).map((u) => UserModel.fromJson(u)));
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
        _selected = List<bool>.filled(_friends.length, false);
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data?['message']?.toString() ?? 'Error'),
      duration: const Duration(seconds: 4),
    ));
  }

  Future<void> _addToGroup() async {
    setState(() => _apiFetching = true);
    final selectedUsers = <String>[
      for (int i = 0; i < _selected.length; i++)
        if (_selected[i]) _friends[i].id,
    ];

    if (!mounted) return;
    final data = await AppHttpClient.post(
        context, '/trip/${widget.trip.id}/add-many', {'users': selectedUsers});
    if (!mounted) return;
    setState(() => _apiFetching = false);

    if (data != null && data['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'].toString()),
        duration: const Duration(seconds: 4),
      ));
      final modified = List<TripMemberModel>.from(
          (data['data'] as List).map((x) => TripMemberModel.fromJson(x)));
      final updated = widget.trip.copyWith(users: modified);
      await HiveBoxes.trips.put(widget.trip.id, updated);
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data?['message']?.toString() ?? 'Error'),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Add people to group',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasSelection)
            _apiFetching
                ? Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 30,
                    height: 30,
                    child: const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: () {
                      Haptics.medium();
                      _addToGroup();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Center(
                        child: Text('Done',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ),
        ],
      ),
      body: ListView.builder(
        itemCount: _friends.length + 3,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return GestureDetector(
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
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(22.5)),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(color: Colors.cyan[200]),
                      child: Center(
                        child: Icon(Icons.group_add, color: Colors.purple[400]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Add a new contact to Splittr',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            );
          }
          if (idx == 1) {
            return const Padding(
              padding: EdgeInsets.only(top: 20, left: 10, bottom: 15),
              child: Text('Friends on Splittr',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            );
          }
          if (idx == _friends.length + 2) {
            return Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Haptics.medium();
                    _refreshFriends();
                  },
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: AppColors.primary,
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text('Refresh Friends List',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                ),
              ],
            );
          }
          final index = idx - 2;
          final friend = _friends[index];
          final alreadyIn = _involvedUsers.contains(friend.id);
          return GestureDetector(
            onTap: () {
              if (!alreadyIn) {
                Haptics.medium();
                setState(() {
                  _selected[index] = !_selected[index];
                });
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Opacity(
                  opacity: alreadyIn ? 0.3 : 1.0,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      ClipOval(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/profile/${friend.dp}.png'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(friend.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15)),
                          if (alreadyIn)
                            const Text('Already in group',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      if (_selected[index])
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
