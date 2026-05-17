import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class RemoveFromGroupScreen extends StatefulWidget {
  const RemoveFromGroupScreen({super.key, required this.trip});

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
    _selected = List.filled(_users.length, false);
    _allowed = List.filled(_users.length, true);

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
      if (double.parse(raw.toStringAsFixed(2)) != 0.0) {
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
    final data = await AppHttpClient.post(context,
        '/trip/${widget.trip.id}/leave-many', {'users': selectedUsers});
    if (!mounted) return;
    setState(() => _loading = false);

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
        title: const Text('Remove people from group',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasSelection)
            _loading
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
                      _removeFromGroup();
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
        itemCount: _users.length + 1,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return const Padding(
              padding: EdgeInsets.only(top: 20, left: 10, bottom: 15),
              child: Text('Friends in this group',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
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
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Opacity(
                  opacity: _allowed[index] ? 1.0 : 0.3,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      ClipOval(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset(
                              'assets/profile/${_users[index].dp}.png'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_users[index].name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15)),
                          if (!_allowed[index])
                            const Text('Remaining Unsettled balances',
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
