import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_category_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_paid_by_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_paid_for_screen.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.trip,
    this.updating = false,
    this.expense,
  });

  final TripModel trip;
  final bool updating;
  final ExpenseModel? expense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _category = 'general';
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _amount = '0.00';
  late UserModel _user;

  bool _loading = true;
  bool _nameValid = true;

  splitTypeEnum _splitType = splitTypeEnum.equal;
  List<By> _paidBy = [];
  List<By> _paidFor = [];
  Map<String, TripMemberModel> _tripUserMap = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _init();

    ref.listenManual<AsyncValue<ExpenseSavedData>>(
      expenseNotifierProvider,
      (_, next) {
        next.whenOrNull(
          error: (e, _) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _showSnack(e.toString());
            });
          },
          data: (result) {
            if (!mounted) return;

            if (result.action == ExpenseAction.saved) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(
                    context,
                    {
                      'changed': true,
                      'expense': result.expense,
                    },
                  );
                }
              });
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _user = UserModel.fromJson(
        jsonDecode(prefs.getString('user')!) as Map<String, dynamic>);

    final tempBy = <By>[], tempFor = <By>[];
    final userMap = <String, TripMemberModel>{};
    for (final tu in widget.trip.users) {
      if (!tu.involved) continue;
      if (tu.user == _user.id) tempBy.add(By(tu.id, 0, 0));
      tempFor.add(By(tu.id, 0, 0));
      userMap[tu.id] = tu;
    }

    if (widget.updating && widget.expense != null) {
      setState(() {
        _nameController.text = widget.expense!.name;
        _amount = widget.expense!.amount.toStringAsFixed(2);
        _amountController.text = _amount;
        _category = widget.expense!.category;
        _splitType = widget.expense!.splitTypeEnum;
        _paidBy = widget.expense!.paidBy
            .map((e) => By(e.user, e.amount, e.shareOrPercent))
            .toList();
        _paidFor = widget.expense!.paidFor
            .map((e) => By(e.user, e.amount, e.shareOrPercent))
            .toList();
        _selectedDate = widget.expense!.created;
        _tripUserMap = userMap;
        _loading = false;
      });
    } else {
      setState(() {
        _paidBy = tempBy;
        _paidFor = tempFor;
        _tripUserMap = userMap;
        _loading = false;
      });
    }
  }

  String _timeStr(DateTime d) {
    int h = d.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> _pickCategory() async {
    Haptics.medium();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => ChooseCategoryScreen(current: _category)),
    );
    if (!mounted || result == null) return;
    setState(() => _category = result);
  }

  Future<void> _pickPaidBy() async {
    Haptics.medium();
    final result = await Navigator.push<List<By>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChoosePaidByScreen(
          tripUserMap: _tripUserMap,
          paidBy: _paidBy,
          amount: double.parse(_amount),
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _paidBy = result);
  }

  Future<void> _pickPaidFor() async {
    Haptics.medium();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChoosePaidForScreen(
          tripUserMap: _tripUserMap,
          paidFor: _paidFor,
          amount: double.parse(_amount),
          splitType: _splitType,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _splitType = result['type'] as splitTypeEnum;
      _paidFor = result['paid_for'] as List<By>;
    });
  }

  // Equal-split preview helper (amount display only — final calc in controller)
  void _adjustEqualPreview() {
    if (_splitType != splitTypeEnum.equal) return;
    final amnt = double.parse(_amount);
    final n = _paidFor.length;
    if (n == 0) return;
    final per = AmountFormatter.round2(amnt / n);
    for (int i = 0; i < _paidFor.length; i++) {
      _paidFor[i].amount = per;
    }
  }

  String _paidByLabel() {
    if (_paidBy.isEmpty) return 'You';
    if (_paidBy.length == 1) {
      return _tripUserMap[_paidBy[0].user]?.name ?? 'Unknown';
    }
    return '${_paidBy.length} people';
  }

  String _splitLabel() {
    switch (_splitType) {
      case splitTypeEnum.equal:
        return 'Equally';
      case splitTypeEnum.unequal:
        return 'Unequally';
      case splitTypeEnum.shares:
        return 'By shares';
      case splitTypeEnum.percent:
        return 'By %';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseAsync = ref.watch(expenseNotifierProvider);
    final notifier = ref.read(expenseNotifierProvider.notifier);
    final saving = expenseAsync.isLoading;

    return Stack(
      children: [
        Opacity(
          opacity: (_loading || saving) ? 0.5 : 1,
          child: Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                widget.updating ? 'Update Expense' : 'Add Expense',
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () =>
                    Navigator.pop(context, {'changed': false, 'expense': null}),
              ),
              actions: [
                IconButton(
                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.done, color: Colors.white),
                  onPressed: saving
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_nameController.text.isEmpty) {
                            setState(() => _nameValid = false);
                            return;
                          }
                          _adjustEqualPreview();
                          notifier.save(
                            trip: widget.trip,
                            name: _nameController.text,
                            amount: double.parse(_amount),
                            category: _category,
                            splitType: _splitType,
                            paidBy: _paidBy,
                            paidFor: _paidFor,
                            created: _selectedDate,
                            expenseId:
                                widget.updating ? widget.expense!.id : null,
                          );
                        },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('With you and: ',
                          style: TextStyle(color: Colors.white)),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xffa0a0a0), width: 0.5),
                        ),
                        child: Center(
                          child: Text('All of ${widget.trip.name}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: _pickCategory,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                  'assets/categories/$_category.png',
                                  height: 45,
                                  width: 45),
                            ),
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xffa0a0a0), width: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: AppColors.primary,
                          onChanged: (_) => setState(() => _nameValid = true),
                          decoration: _nameValid
                              ? InputDecoration(
                                  border: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.primary)),
                                  labelText: 'Description',
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  fillColor: Colors.grey[900],
                                  filled: true,
                                  contentPadding: EdgeInsets.zero,
                                )
                              : const InputDecoration(
                                  errorText: 'Please enter a description'),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.currency_rupee_outlined,
                              color: Colors.white),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) =>
                              setState(() => _amount = v.isEmpty ? '0.00' : v),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.primary)),
                            labelText: '0.00',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            fillColor: Colors.grey[900],
                            filled: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          color: Colors.white),
                      GestureDetector(
                        onTap: () async {
                          Haptics.medium();
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setState(() => _selectedDate = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  _selectedDate.hour,
                                  _selectedDate.minute,
                                ).toLocal());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xffa0a0a0), width: 0.5)),
                            ),
                            child: Center(
                              child: Text(
                                '${_selectedDate.day} '
                                '${_months[_selectedDate.month - 1]} '
                                '${_selectedDate.year}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_outlined,
                          color: Colors.white),
                      GestureDetector(
                        onTap: () async {
                          Haptics.medium();
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (t != null) {
                            setState(() => _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day,
                                  t.hour,
                                  t.minute,
                                ).toLocal());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xffa0a0a0), width: 0.5)),
                            ),
                            child: Center(
                              child: Text(_timeStr(_selectedDate),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickPaidBy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: const Color(0xffa0a0a0), width: 0.5),
                          ),
                          child: Text(
                            'Paid by: ${_paidByLabel()}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _pickPaidFor,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: const Color(0xffa0a0a0), width: 0.5),
                          ),
                          child: Text(
                            'Split: ${_splitLabel()}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loading || saving)
          const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
      ],
    );
  }
}
