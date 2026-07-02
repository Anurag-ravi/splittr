import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_category_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_paid_by_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/choose_paid_for_screen.dart';
import 'package:splittr/features/expenses/presentation/states/expense_state.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

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

  TripModel get _initialTrip => widget.trip;
  late TripModel _selectedTrip = _initialTrip;

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

              _showSnack(
                e.toString(),
              );
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _user = UserModel.fromJson(
      jsonDecode(
        prefs.getString('user')!,
      ) as Map<String, dynamic>,
    );

    final tempBy = <By>[];

    final tempFor = <By>[];

    final userMap = <String, TripMemberModel>{};

    for (final tu in _selectedTrip.users) {
      if (!tu.involved) continue;

      if (tu.user == _user.id) {
        tempBy.add(
          By(tu.id, 0, 0),
        );
      }

      tempFor.add(
        By(tu.id, 0, 0),
      );

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
            .map(
              (e) => By(
                e.user,
                e.amount,
                e.shareOrPercent,
              ),
            )
            .toList();

        _paidFor = widget.expense!.paidFor
            .map(
              (e) => By(
                e.user,
                e.amount,
                e.shareOrPercent,
              ),
            )
            .toList();

        _selectedDate = widget.expense!.created;

        _tripUserMap = userMap;

        _loading = false;
      });
    } else {
      setState(() {
        _nameController.clear();
        _amountController.clear();
        _amount = '0.00';
        _category = 'general';
        _splitType = splitTypeEnum.equal;
        _selectedDate = DateTime.now();
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

    return '${h.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')} '
        '$ampm';
  }

  Future<void> _pickCategory() async {
    Haptics.medium();

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseCategoryScreen(
          current: _category,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _category = result;
    });
  }

  Future<void> _pickPaidBy() async {
    Haptics.medium();

    final result = await Navigator.push<List<By>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChoosePaidByScreen(
          tripUserMap: _tripUserMap,
          paidBy: _paidBy,
          amount: double.parse(
            _amount,
          ),
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _paidBy = result;
    });
  }

  Future<void> _pickPaidFor() async {
    Haptics.medium();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChoosePaidForScreen(
          tripUserMap: _tripUserMap,
          paidFor: _paidFor,
          amount: double.parse(
            _amount,
          ),
          splitType: _splitType,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _splitType = result['type'] as splitTypeEnum;

      _paidFor = result['paid_for'] as List<By>;
    });
  }

  void _adjustEqualPreview() {
    if (_splitType != splitTypeEnum.equal) {
      return;
    }

    final amnt = double.parse(_amount);

    final n = _paidFor.length;

    if (n == 0) return;

    final per = AmountFormatter.round2(
      amnt / n,
    );

    for (int i = 0; i < _paidFor.length; i++) {
      _paidFor[i].amount = per;
    }
  }

  String _paidByLabel() {
    if (_paidBy.isEmpty) {
      return 'You';
    }

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
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final expenseAsync = ref.watch(
      expenseNotifierProvider,
    );

    final notifier = ref.read(
      expenseNotifierProvider.notifier,
    );

    final saving = expenseAsync.isLoading;

    return Stack(
      children: [
        Opacity(
          opacity: (_loading || saving) ? 0.5 : 1,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // =====================
                  // HEADER
                  // =====================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      10,
                      10,
                      12,
                    ),
                    child: Row(
                      children: [
                        _topActionButton(
                          context,
                          icon: Icons.close_rounded,
                          onTap: () {
                            Navigator.pop(
                              context,
                              {
                                'changed': false,
                                'expense': null,
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            widget.updating ? 'Update Expense' : 'Add Expense',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: saving
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  if (_nameController.text.trim().isEmpty) {
                                    setState(() {
                                      _nameValid = false;
                                    });

                                    return;
                                  }

                                  _adjustEqualPreview();

                                  notifier.save(
                                    trip: _selectedTrip,
                                    name: _nameController.text,
                                    amount: double.parse(
                                      _amount,
                                    ),
                                    category: _category,
                                    splitType: _splitType,
                                    paidBy: _paidBy,
                                    paidFor: _paidFor,
                                    created: _selectedDate,
                                    expenseId: widget.updating
                                        ? widget.expense!.id
                                        : null,
                                  );
                                },
                          child: saving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : NeonGlow(
                                  color: colorScheme.primary,
                                  radius: 18,
                                  spread: -2,
                                  glowOpacity: 0.16,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.primary.withOpacity(
                                            0.88,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: colorScheme.onPrimary,
                                      size: 26,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        10,
                        10,
                        32,
                      ),
                      child: Column(
                        children: [
                          // =====================
                          // GROUP CHIP
                          // =====================

                          Row(
                            children: [
                              Text(
                                'With:',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(
                                    0.68,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (widget.updating)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    color: colorScheme.surface.withOpacity(
                                      0.72,
                                    ),
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(
                                        0.08,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _selectedTrip.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    color: colorScheme.surface.withOpacity(
                                      0.72,
                                    ),
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(
                                        0.08,
                                      ),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedTrip.id,
                                    underline: const SizedBox.shrink(),
                                    dropdownColor: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: HiveBoxes.trips.values
                                        .map(
                                          (trip) => DropdownMenuItem<String>(
                                            value: trip.id,
                                            child: Text(trip.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (tripId) {
                                      if (tripId == null ||
                                          tripId == _selectedTrip.id) return;
                                      final newTrip = HiveBoxes.trips.values
                                          .firstWhere((t) => t.id == tripId);
                                      setState(() {
                                        _selectedTrip = newTrip;
                                        _loading = true;
                                      });
                                      _init();
                                    },
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // =====================
                          // MAIN CARD
                          // =====================

                          NeonGlow(
                            color: colorScheme.primary,
                            radius: 32,
                            spread: -10,
                            glowOpacity: 0.14,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  28,
                                ),
                                color: colorScheme.surface.withOpacity(
                                  theme.brightness == Brightness.dark
                                      ? 0.92
                                      : 0.97,
                                ),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(
                                    0.10,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // =================
                                  // CATEGORY + NAME
                                  // =================

                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickCategory,
                                        child: Container(
                                          width: 78,
                                          height: 78,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                colorScheme.primary.withOpacity(
                                                  0.18,
                                                ),
                                                colorScheme.primary.withOpacity(
                                                  0.05,
                                                ),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: colorScheme.primary
                                                  .withOpacity(
                                                0.10,
                                              ),
                                            ),
                                          ),
                                          child: CategoryIcon(
                                            category: _category,
                                            entityType: 'expense',
                                            size: 72,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 14,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          cursorColor: colorScheme.primary,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          onChanged: (_) {
                                            setState(
                                              () {
                                                _nameValid = true;
                                              },
                                            );
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'What was this expense?',
                                            errorText: _nameValid
                                                ? null
                                                : 'Enter description',
                                            hintStyle: theme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                              color: theme
                                                  .textTheme.bodyMedium?.color
                                                  ?.withOpacity(
                                                0.34,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 28,
                                  ),

                                  // =================
                                  // AMOUNT
                                  // =================

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                      color: colorScheme.surface.withOpacity(
                                        0.72,
                                      ),
                                      border: Border.all(
                                        color: colorScheme.primary.withOpacity(
                                          0.08,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color:
                                                colorScheme.primary.withOpacity(
                                              0.10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.currency_rupee_rounded,
                                            color: colorScheme.primary,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _amountController,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                              decimal: true,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ),
                                            ],
                                            cursorColor: colorScheme.primary,
                                            style: theme.textTheme.displaySmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -1,
                                            ),
                                            onChanged: (
                                              v,
                                            ) {
                                              setState(
                                                () {
                                                  _amount =
                                                      v.isEmpty ? '0.00' : v;
                                                },
                                              );
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: '0.00',
                                              hintStyle: theme
                                                  .textTheme.displaySmall
                                                  ?.copyWith(
                                                color: theme
                                                    .textTheme.bodyMedium?.color
                                                    ?.withOpacity(
                                                  0.28,
                                                ),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 22,
                                  ),

                                  // =================
                                  // DATE TIME
                                  // =================

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _modernPicker(
                                          context,
                                          icon: Icons.calendar_month_rounded,
                                          text:
                                              '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                                          onTap: () async {
                                            Haptics.medium();

                                            final d = await showDatePicker(
                                              context: context,
                                              initialDate: _selectedDate,
                                              firstDate: DateTime(
                                                2000,
                                              ),
                                              lastDate: DateTime.now(),
                                            );

                                            if (d != null) {
                                              setState(
                                                () {
                                                  _selectedDate = DateTime(
                                                    d.year,
                                                    d.month,
                                                    d.day,
                                                    _selectedDate.hour,
                                                    _selectedDate.minute,
                                                  ).toLocal();
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 14,
                                      ),
                                      Expanded(
                                        child: _modernPicker(
                                          context,
                                          icon: Icons.access_time_rounded,
                                          text: _timeStr(
                                            _selectedDate,
                                          ),
                                          onTap: () async {
                                            Haptics.medium();

                                            final t = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                _selectedDate,
                                              ),
                                            );

                                            if (t != null) {
                                              setState(
                                                () {
                                                  _selectedDate = DateTime(
                                                    _selectedDate.year,
                                                    _selectedDate.month,
                                                    _selectedDate.day,
                                                    t.hour,
                                                    t.minute,
                                                  ).toLocal();
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 22,
                                  ),

                                  // =================
                                  // ACTION CARDS
                                  // =================

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _actionCard(
                                          context,
                                          icon: Icons.payments_rounded,
                                          title: 'Paid by',
                                          value: _paidByLabel(),
                                          onTap: _pickPaidBy,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 14,
                                      ),
                                      Expanded(
                                        child: _actionCard(
                                          context,
                                          icon: Icons.pie_chart_outline_rounded,
                                          title: 'Split',
                                          value: _splitLabel(),
                                          onTap: _pickPaidFor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loading || saving)
          Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            22,
          ),
          color: colorScheme.surface.withOpacity(0.72),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  14,
                ),
                color: colorScheme.primary.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.66,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernPicker(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            22,
          ),
          color: colorScheme.surface.withOpacity(0.72),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.72),
              borderRadius: BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.08),
              ),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
