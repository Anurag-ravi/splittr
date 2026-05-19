import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class ChoosePaidForScreen extends StatefulWidget {
  const ChoosePaidForScreen({
    super.key,
    required this.tripUserMap,
    required this.paidFor,
    required this.amount,
    required this.splitType,
  });

  final Map<String, TripMemberModel> tripUserMap;
  final List<By> paidFor;
  final double amount;
  final splitTypeEnum splitType;

  @override
  State<ChoosePaidForScreen> createState() => _ChoosePaidForScreenState();
}

class _ChoosePaidForScreenState extends State<ChoosePaidForScreen>
    with TickerProviderStateMixin {
  late List<TripMemberModel> _users;
  late List<ByEqual> _paidEqually;
  late List<By> _paidUnequally;
  late List<ByShare> _paidByShare;
  late List<TextEditingController> _controllers;
  late List<TextEditingController> _shareControllers;
  late TabController _tabController;

  double _total = 0;
  int _totalShare = 0;
  bool _allInvolved = false;
  int _person = 0;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _users = widget.tripUserMap.values.toList();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animateTo(widget.splitType.index);
    _tabController.addListener(() {
      setState(() => _tabIndex = _tabController.index);
    });
    _tabIndex = widget.splitType.index;

    _paidEqually = _users.map((e) => ByEqual(e.id, false)).toList();
    _paidUnequally = _users.map((e) => By(e.id, 0, 0)).toList();
    _paidByShare = _users.map((e) => ByShare(e.id, 0)).toList();

    _controllers = _users.map((_) => TextEditingController(text: '')).toList();
    _shareControllers =
        _users.map((_) => TextEditingController(text: '')).toList();

    if (widget.splitType == splitTypeEnum.equal) {
      for (int i = 0; i < _paidEqually.length; i++) {
        for (final b in widget.paidFor) {
          if (_paidEqually[i].user == b.user) {
            _paidEqually[i].involved = true;
          }
        }
      }
      _allInvolved = widget.paidFor.length == _users.length;
      _person = widget.paidFor.length;
    }

    if (widget.splitType == splitTypeEnum.unequal) {
      for (int i = 0; i < _paidUnequally.length; i++) {
        for (final b in widget.paidFor) {
          if (_paidUnequally[i].user == b.user) {
            _paidUnequally[i].amount = b.amount;
            _total += b.amount;
          }
        }
      }
      _controllers = _paidUnequally.map((b) {
        return TextEditingController(
            text: b.amount != 0 ? b.amount.toStringAsFixed(2) : '');
      }).toList();
    }

    if (widget.splitType == splitTypeEnum.shares) {
      for (int i = 0; i < _paidByShare.length; i++) {
        for (final b in widget.paidFor) {
          if (_paidByShare[i].user == b.user) {
            _paidByShare[i].share = b.share_or_percent.toInt();
            _totalShare += b.share_or_percent.toInt();
          }
        }
      }
      _shareControllers = _paidByShare.map((b) {
        return TextEditingController(
            text: b.share != 0 ? b.share.toString() : '');
      }).toList();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers) c.dispose();
    for (final c in _shareControllers) c.dispose();
    super.dispose();
  }

  bool get _checkValid {
    if (_tabIndex == 0) return _person > 0;
    if (_tabIndex == 1) {
      return _total.toStringAsFixed(2) == widget.amount.toStringAsFixed(2);
    }
    return _totalShare > 0;
  }

  void _onDone() {
    final temp = <By>[];
    if (_tabController.index == 0) {
      for (final x in _paidEqually) {
        if (x.involved) temp.add(By(x.user, 0, 0));
      }
      Navigator.pop(context, {'type': splitTypeEnum.equal, 'paid_for': temp});
    } else if (_tabController.index == 1) {
      if (widget.amount != _total) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Amounts do not add up to ${widget.amount}'),
          duration: const Duration(seconds: 4),
        ));
        return;
      }
      for (final x in _paidUnequally) {
        if (x.amount > 0) temp.add(By(x.user, x.amount, 0));
      }
      Navigator.pop(context, {'type': splitTypeEnum.unequal, 'paid_for': temp});
    } else {
      if (_totalShare == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Shares cannot be 0'),
          duration: Duration(seconds: 4),
        ));
        return;
      }
      double tot = 0;
      for (final x in _paidByShare) {
        if (x.share > 0) {
          final cAmnt = AmountFormatter.round2(
              (widget.amount * x.share) / (_totalShare + 0.0));
          tot += cAmnt;
          temp.add(By(x.user, cAmnt, x.share + 0.0));
        }
      }
      double diff = double.parse((widget.amount - tot).toStringAsFixed(2));
      int i = 0;
      while (diff >= 0.01) {
        temp[i % temp.length].amount = double.parse(
            (temp[i % temp.length].amount + 0.01).toStringAsFixed(2));
        diff -= 0.01;
        i++;
      }
      Navigator.pop(context, {'type': splitTypeEnum.shares, 'paid_for': temp});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            const Text('Adjust split', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(
              context, {'type': widget.splitType, 'paid_for': widget.paidFor}),
        ),
        actions: [
          if (_checkValid)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _onDone,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
                child: Text('Equally',
                    style: TextStyle(color: Colors.white, fontSize: 12))),
            Tab(
                child: Text('Unequally',
                    style: TextStyle(color: Colors.white, fontSize: 12))),
            Tab(
                child: Text('Share',
                    style: TextStyle(color: Colors.white, fontSize: 12))),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: _tabController,
        children: [
          _equalTab(),
          _unequalTab(),
          _shareTab(),
        ],
      ),
    );
  }

  Widget _equalTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _person > 0
                      ? '₹${(_person > 0 ? widget.amount / _person : 0).toStringAsFixed(2)} per person'
                      : 'You must select at least 1 person',
                  style: TextStyle(
                    color: _person > 0 ? Colors.white : Colors.redAccent,
                    fontSize: _person > 0 ? 15 : 12,
                  ),
                ),
                Text('$_person person',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            Row(
              children: [
                const Text('All ',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                Checkbox(
                  value: _allInvolved,
                  onChanged: (_) {
                    setState(() {
                      _paidEqually = _paidEqually
                          .map((e) => ByEqual(e.user, !_allInvolved))
                          .toList();
                      _person = _allInvolved ? 0 : _users.length;
                      _allInvolved = !_allInvolved;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _paidEqually[i].involved = !_paidEqually[i].involved;
                int c = _paidEqually.where((e) => !e.involved).length;
                _allInvolved = c == 0;
                _person = _users.length - c;
              });
            },
            child: Padding(
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
                        child: ProfileImage(id: _users[i].name),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(_users[i].name,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                      value: _paidEqually[i].involved,
                      onChanged: (_) {
                        setState(() {
                          _paidEqually[i].involved = !_paidEqually[i].involved;
                          int c = _paidEqually.where((e) => !e.involved).length;
                          _allInvolved = c == 0;
                          _person = _users.length - c;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _unequalTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SizedBox(
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
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, i) {
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
                      child: ProfileImage(id: _users[i].name),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(_users[i].name,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 30,
                    child: TextField(
                      controller: _controllers[i],
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
                          _paidUnequally[i].amount =
                              input.isNotEmpty ? double.parse(input) : 0;
                          _total =
                              _paidUnequally.fold(0, (s, b) => s + b.amount);
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
      ),
    );
  }

  Widget _shareTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Center(
          child: Text(
            '$_totalShare total shares',
            style: TextStyle(
              color: _totalShare != 0 ? Colors.white : Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, i) {
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
                      child: ProfileImage(id: _users[i].name),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_users[i].name,
                            style: const TextStyle(color: Colors.white)),
                        Text(
                          _totalShare == 0
                              ? '₹0.00'
                              : '₹${((widget.amount * _paidByShare[i].share) / (_totalShare + 0.0)).toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 30,
                    child: TextField(
                      controller: _shareControllers[i],
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                      ],
                      cursorColor: AppColors.primary,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (input) {
                        setState(() {
                          _paidByShare[i].share =
                              input.isNotEmpty ? int.parse(input) : 0;
                          _totalShare =
                              _paidByShare.fold(0, (s, b) => s + b.share);
                        });
                      },
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                        labelText: '0',
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
      ),
    );
  }
}
