import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/models/split_ui_models.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

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

    _users = widget.tripUserMap.values.where((e) => e.involved).toList();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _tabController.animateTo(
      widget.splitType.index,
    );

    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });

    _tabIndex = widget.splitType.index;

    _paidEqually = _users
        .map(
          (e) => ByEqual(
            e.id,
            false,
          ),
        )
        .toList();

    _paidUnequally = _users
        .map(
          (e) => By(
            e.id,
            0,
            0,
          ),
        )
        .toList();

    _paidByShare = _users
        .map(
          (e) => ByShare(
            e.id,
            0,
          ),
        )
        .toList();

    _controllers = _users
        .map(
          (_) => TextEditingController(),
        )
        .toList();

    _shareControllers = _users
        .map(
          (_) => TextEditingController(),
        )
        .toList();

    // =====================
    // EQUAL
    // =====================

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

    // =====================
    // UNEQUAL
    // =====================

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
          text: b.amount != 0
              ? b.amount.toStringAsFixed(
                  2,
                )
              : '',
        );
      }).toList();
    }

    // =====================
    // SHARE
    // =====================

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
          text: b.share != 0 ? b.share.toString() : '',
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();

    for (final c in _controllers) {
      c.dispose();
    }

    for (final c in _shareControllers) {
      c.dispose();
    }

    super.dispose();
  }

  bool get _checkValid {
    if (_tabIndex == 0) {
      return _person > 0;
    }

    if (_tabIndex == 1) {
      return (_total - widget.amount).abs() < 0.01;
    }

    return _totalShare > 0;
  }

  void _onDone() {
    final temp = <By>[];

    // =====================
    // EQUAL
    // =====================

    if (_tabController.index == 0) {
      for (final x in _paidEqually) {
        if (x.involved) {
          temp.add(
            By(
              x.user,
              0,
              0,
            ),
          );
        }
      }

      Navigator.pop(
        context,
        {
          'type': splitTypeEnum.equal,
          'paid_for': temp,
        },
      );
    }

    // =====================
    // UNEQUAL
    // =====================

    else if (_tabController.index == 1) {
      if ((_total - widget.amount).abs() > 0.01) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Amounts do not add up to ₹${widget.amount.toStringAsFixed(2)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      for (final x in _paidUnequally) {
        if (x.amount > 0) {
          temp.add(
            By(
              x.user,
              x.amount,
              0,
            ),
          );
        }
      }

      Navigator.pop(
        context,
        {
          'type': splitTypeEnum.unequal,
          'paid_for': temp,
        },
      );
    }

    // =====================
    // SHARES
    // =====================

    else {
      if (_totalShare == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Shares cannot be 0',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      double tot = 0;

      for (final x in _paidByShare) {
        if (x.share > 0) {
          final cAmnt = AmountFormatter.round2(
            (widget.amount * x.share) / (_totalShare + 0.0),
          );

          tot += cAmnt;

          temp.add(
            By(
              x.user,
              cAmnt,
              x.share + 0.0,
            ),
          );
        }
      }

      double diff = double.parse(
        (widget.amount - tot).toStringAsFixed(2),
      );

      int i = 0;

      while (diff >= 0.01) {
        temp[i % temp.length].amount = double.parse(
          (temp[i % temp.length].amount + 0.01).toStringAsFixed(
            2,
          ),
        );

        diff -= 0.01;

        i++;
      }

      Navigator.pop(
        context,
        {
          'type': splitTypeEnum.shares,
          'paid_for': temp,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
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
                10,
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
                          'type': widget.splitType,
                          'paid_for': widget.paidFor,
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust Split',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Choose how expense is divided',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.textTheme.bodyMedium?.color?.withOpacity(
                              0.68,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_checkValid)
                    GestureDetector(
                      onTap: _onDone,
                      child: NeonGlow(
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

            // =====================
            // TABS
            // =====================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    22,
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
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    color: colorScheme.primary.withOpacity(
                      0.14,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor:
                      theme.textTheme.bodyMedium?.color?.withOpacity(
                    0.64,
                  ),
                  labelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(
                      text: 'Equal',
                    ),
                    Tab(
                      text: 'Unequal',
                    ),
                    Tab(
                      text: 'Shares',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _equalTab(),
                  _unequalTab(),
                  _shareTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // EQUAL TAB
  // =====================

  Widget _equalTab() {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final perPerson = _person > 0 ? widget.amount / _person : 0.0;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              24,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per Person',
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
                      '₹${perPerson.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: colorScheme.outline.withOpacity(
                  0.12,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'People',
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
                      '$_person',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: GestureDetector(
            onTap: () {
              Haptics.medium();

              setState(() {
                _paidEqually = _paidEqually
                    .map(
                      (e) => ByEqual(
                        e.user,
                        !_allInvolved,
                      ),
                    )
                    .toList();

                _person = _allInvolved ? 0 : _users.length;

                _allInvolved = !_allInvolved;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  20,
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
                  Icon(
                    Icons.groups_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      'Include everyone',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    value: _allInvolved,
                    onChanged: (_) {
                      Haptics.medium();

                      setState(() {
                        _paidEqually = _paidEqually
                            .map(
                              (e) => ByEqual(
                                e.user,
                                !_allInvolved,
                              ),
                            )
                            .toList();

                        _person = _allInvolved ? 0 : _users.length;

                        _allInvolved = !_allInvolved;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              10,
              0,
              10,
              24,
            ),
            itemCount: _users.length,
            itemBuilder: (context, i) {
              final user = _users[i];

              final selected = _paidEqually[i].involved;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: GestureDetector(
                  onTap: () {
                    Haptics.medium();

                    setState(() {
                      _paidEqually[i].involved = !_paidEqually[i].involved;

                      int c = _paidEqually
                          .where(
                            (e) => !e.involved,
                          )
                          .length;

                      _allInvolved = c == 0;

                      _person = _users.length - c;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                      color: colorScheme.surface.withOpacity(
                        theme.brightness == Brightness.dark ? 0.92 : 0.97,
                      ),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary.withOpacity(
                                0.18,
                              )
                            : colorScheme.outline.withOpacity(
                                0.08,
                              ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: ProfileImage(
                            id: user.name,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                selected
                                    ? 'Included in split'
                                    : 'Tap to include',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected
                                      ? colorScheme.primary
                                      : theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(
                                          0.64,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 220,
                          ),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(
                                      0.22,
                                    ),
                            ),
                          ),
                          child: selected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: colorScheme.onPrimary,
                                  size: 18,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =====================
  // UNEQUAL TAB
  // =====================

  Widget _unequalTab() {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              24,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned',
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
                      '₹${_total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: colorScheme.outline.withOpacity(
                  0.12,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.amount - _total >= 0 ? 'Remaining' : 'Exceeded',
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
                      '₹${(widget.amount - _total).abs().toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.amount - _total >= 0
                            ? Colors.white
                            : colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              10,
              0,
              10,
              24,
            ),
            itemCount: _users.length,
            itemBuilder: (context, i) {
              final user = _users[i];

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                    color: colorScheme.surface.withOpacity(
                      theme.brightness == Brightness.dark ? 0.92 : 0.97,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: ProfileImage(
                          id: user.name,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Enter custom amount',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(
                                  0.64,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: 110,
                        child: Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
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
                              Text(
                                '₹',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controllers[i],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                        r'^\d+\.?\d{0,2}',
                                      ),
                                    ),
                                  ],
                                  cursorColor: colorScheme.primary,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onChanged: (
                                    input,
                                  ) {
                                    setState(
                                      () {
                                        _paidUnequally[i].amount =
                                            input.isNotEmpty
                                                ? double.parse(
                                                    input,
                                                  )
                                                : 0;

                                        _total = _paidUnequally.fold(
                                          0,
                                          (
                                            s,
                                            b,
                                          ) =>
                                              s + b.amount,
                                        );
                                      },
                                    );
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
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
              );
            },
          ),
        ),
      ],
    );
  }

  // =====================
  // SHARE TAB
  // =====================

  Widget _shareTab() {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              24,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Shares',
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
                      '$_totalShare',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: colorScheme.outline.withOpacity(
                  0.12,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount',
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
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              10,
              0,
              10,
              24,
            ),
            itemCount: _users.length,
            itemBuilder: (context, i) {
              final user = _users[i];

              final calcAmount = _totalShare == 0
                  ? 0.0
                  : (widget.amount * _paidByShare[i].share) /
                      (_totalShare + 0.0);

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                    color: colorScheme.surface.withOpacity(
                      theme.brightness == Brightness.dark ? 0.92 : 0.97,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: ProfileImage(
                          id: user.name,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '₹${calcAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: 110,
                        child: Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
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
                              Text(
                                'x',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _shareControllers[i],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                        r'^\d+',
                                      ),
                                    ),
                                  ],
                                  cursorColor: colorScheme.primary,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onChanged: (
                                    input,
                                  ) {
                                    setState(
                                      () {
                                        _paidByShare[i].share = input.isNotEmpty
                                            ? int.parse(
                                                input,
                                              )
                                            : 0;

                                        _totalShare = _paidByShare.fold(
                                          0,
                                          (
                                            s,
                                            b,
                                          ) =>
                                              s + b.share,
                                        );
                                      },
                                    );
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
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
              );
            },
          ),
        ),
      ],
    );
  }

  // =====================
  // TOP ACTION BUTTON
  // =====================

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
              color: colorScheme.surface.withOpacity(
                0.72,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: colorScheme.primary.withOpacity(
                  0.08,
                ),
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
