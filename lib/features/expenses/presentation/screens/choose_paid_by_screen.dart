import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class ChoosePaidByScreen extends StatefulWidget {
  const ChoosePaidByScreen({
    super.key,
    required this.tripUserMap,
    required this.paidBy,
    required this.amount,
  });

  final Map<String, TripMemberModel> tripUserMap;
  final List<By> paidBy;
  final double amount;

  @override
  State<ChoosePaidByScreen> createState() => _ChoosePaidByScreenState();
}

class _ChoosePaidByScreenState extends State<ChoosePaidByScreen> {
  late List<TripMemberModel> _users;
  late List<By> _multiplePaidBy;
  late List<TextEditingController> _controllers;
  bool _singlePaid = true;
  String _currentPaidUser = '';
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _users = widget.tripUserMap.values.toList();
    _singlePaid = widget.paidBy.length == 1;
    _currentPaidUser = widget.paidBy[0].user;

    _multiplePaidBy = _users.map((e) {
      double amnt = 0;
      for (final b in widget.paidBy) {
        if (b.user == e.id && b.amount > 0) {
          amnt = b.amount;
          _total += amnt;
          break;
        }
      }
      return By(e.id, amnt, 0);
    }).toList();

    _controllers = _multiplePaidBy.map((b) {
      return TextEditingController(
          text: b.amount > 0 ? b.amount.toString() : '');
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Who paid?', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.paidBy),
        ),
        actions: [
          if (!_singlePaid)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {
                if (widget.amount != _total) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Amounts do not add up to ${widget.amount}'),
                    duration: const Duration(seconds: 4),
                  ));
                  return;
                }
                Navigator.pop(
                  context,
                  _multiplePaidBy.where((b) => b.amount > 0).toList(),
                );
              },
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _singlePaid
          ? const SizedBox.shrink()
          : SizedBox(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹${_total.toStringAsFixed(2)} of ₹${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    widget.amount - _total >= 0
                        ? '₹${(widget.amount - _total).toStringAsFixed(2)} left'
                        : '₹${(_total - widget.amount).toStringAsFixed(2)} over',
                    style: TextStyle(
                      color: widget.amount - _total >= 0
                          ? Colors.white
                          : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
      body: _singlePaid ? _singleList() : _multiList(),
    );
  }

  Widget _singleList() {
    return ListView.builder(
      itemCount: _users.length + 1,
      itemBuilder: (context, index) {
        if (index == _users.length) {
          return GestureDetector(
            onTap: () {
              Haptics.medium();
              setState(() => _singlePaid = false);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text('Multiple people',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }
        return GestureDetector(
          onTap: () {
            Haptics.medium();
            Navigator.pop(context, [By(_users[index].id, widget.amount, 0)]);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/profile/${_users[index].dp}.png',
                    height: 40,
                    width: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Text(_users[index].name,
                    style: const TextStyle(color: Colors.white)),
                const Spacer(),
                if (_currentPaidUser == _users[index].id)
                  const Icon(Icons.check, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _multiList() {
    return ListView.builder(
      itemCount: _users.length + 1,
      itemBuilder: (context, index) {
        if (index == _users.length) {
          return GestureDetector(
            onTap: () {
              Haptics.medium();
              setState(() => _singlePaid = true);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text('Single person paid',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        Image.asset('assets/profile/${_users[index].dp}.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(_users[index].name,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    cursorColor: AppColors.primary,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (input) {
                      setState(() {
                        _multiplePaidBy[index].amount =
                            input.isNotEmpty ? double.parse(input) : 0;
                        _total =
                            _multiplePaidBy.fold(0, (s, b) => s + b.amount);
                      });
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary)),
                      labelText: '0.00',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.grey[900],
                      filled: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
