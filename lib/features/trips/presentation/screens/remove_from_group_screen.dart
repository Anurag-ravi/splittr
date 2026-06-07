// remove_from_group_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class RemoveFromGroupScreen extends StatefulWidget {
  const RemoveFromGroupScreen({
    super.key,
    required this.trip,
  });

  final TripModel trip;

  @override
  State<RemoveFromGroupScreen> createState() => _RemoveFromGroupScreenState();
}

class _RemoveFromGroupScreenState extends State<RemoveFromGroupScreen> {
  late List<TripMemberModel> _users;

  late List<bool> _selected;

  late List<bool> _allowed;

  bool _loading = false;

  bool get _hasSelection => _selected.contains(true);

  @override
  void initState() {
    super.initState();

    _users = widget.trip.users;

    _selected = List.filled(
      _users.length,
      false,
    );

    _allowed = List.filled(
      _users.length,
      true,
    );

    final balances = <String, double>{
      for (final u in _users) u.id: 0.0,
    };

    for (final expense in widget.trip.expenses) {
      for (final b in expense.paidBy) {
        balances[b.user] = (balances[b.user] ?? 0) + b.amount;
      }

      for (final b in expense.paidFor) {
        balances[b.user] = (balances[b.user] ?? 0) - b.amount;
      }
    }

    for (final payment in widget.trip.payments) {
      balances[payment.by] = (balances[payment.by] ?? 0) + payment.amount;

      balances[payment.to] = (balances[payment.to] ?? 0) - payment.amount;
    }

    for (int i = 0; i < _users.length; i++) {
      final raw = balances[_users[i].id] ?? 0;

      if (double.parse(
            raw.toStringAsFixed(2),
          ) !=
          0.0) {
        _allowed[i] = false;
      }
    }
  }

  Future<void> _removeFromGroup() async {
    setState(() => _loading = true);

    final selectedUsers = <String>[
      for (int i = 0; i < _selected.length; i++)
        if (_selected[i]) _users[i].user,
    ];

    if (!mounted) return;

    final data = await AppHttpClient.post(
      context,
      '/trip/${widget.trip.id}/leave-many',
      {
        'users': selectedUsers,
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);

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
          'Remove People',
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
              child: _loading
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

                        _removeFromGroup();
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
        itemCount: _users.length + 1,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 2,
                bottom: 12,
              ),
              child: Text(
                'Friends in this group',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                ),
              ),
            );
          }

          final index = idx - 1;

          return GestureDetector(
            onTap: () {
              if (!_allowed[index]) return;

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
                    ? Colors.red.withOpacity(0.08)
                    : colorScheme.surface.withOpacity(0.88),
                border: Border.all(
                  color: _selected[index]
                      ? Colors.red.withOpacity(0.20)
                      : colorScheme.primary.withOpacity(0.05),
                ),
              ),
              child: Opacity(
                opacity: _allowed[index] ? 1 : 0.35,
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: ProfileImage(
                          id: _users[index].name,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _users[index].name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_allowed[index])
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 2,
                              ),
                              child: Text(
                                'Unsettled balances remaining',
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
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
