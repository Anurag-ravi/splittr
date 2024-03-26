import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/addExpense.dart';
import 'package:splittr/pages/balances.dart';
import 'package:splittr/pages/choosePaymentBy.dart';
import 'package:splittr/pages/expensePage.dart';
import 'package:splittr/pages/paymentPage.dart';
import 'package:splittr/pages/settleUpPage.dart';
import 'package:splittr/pages/totalPage.dart';
import 'package:splittr/pages/tripSettings.dart';
import 'package:splittr/screens/groupScreen.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/excelExport.dart';
import 'package:splittr/utilities/request.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.id, required this.trip});
  final String id;
  final TripModel trip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool loading = true,
      g_free = false,
      export = false,
      g_deletable = false,
      api_fetching = false;
  TripModel? trip;
  List<Transaction> transactions = [];
  String currentTripUser = "";
  String g_involved = "You are all settled up in this group";
  Color g_textColor = Color(0xfff5f5f5);
  Map<String, TripUser> tripUserMap = new Map<String, TripUser>();
  double g_paid_by_me = 0.00, g_paid_for_me = 0.00, g_total = 0.00;
  List months = [
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
    'Dec'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() {
    var user = Boxes.getMe().get('me');
    setState(() {
      trip = Boxes.getTrips().get(widget.id);
    });
    calculate(trip!, user!.id);
  }

  Future<void> refresh() async {
    setState(() {
      api_fetching = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await getRequest(
        "${url!}/trip/${widget.id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        var temp = TripModel.fromJson(data['data']);
        var tripBox = Boxes.getTrips();
        tripBox.put(widget.id, temp);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
        calculate(temp, user.id);
        setState(() {
          api_fetching = false;
        });
        return;
      }
    }
    setState(() {
      api_fetching = false;
    });
  }

  void calculate(TripModel temp, String userId) {
    setState(() {
      g_free = false;
      g_deletable = false;
      tripUserMap = {};
    });
    Map<String, double> tripUserNet = {};
    for (var tu in temp.users) {
      if (tu.user == userId) {
        setState(() {
          currentTripUser = tu.id;
        });
      }
      setState(() {
        tripUserMap.putIfAbsent(tu.id, () => tu);
      });
      tripUserNet.putIfAbsent(tu.id, () => 0.00);
    }
    List<Transaction> t_temp = [];
    double paid_by_me = 0.00, paid_for_me = 0.00, total = 0.00;
    for (var x in temp.expenses) {
      total += x.amount;
      t_temp.add(Transaction(true, x.created, x, null));
      for (var y in x.paid_by) {
        if (y.user == currentTripUser) paid_by_me += y.amount;
        tripUserNet[y.user] = tripUserNet[y.user]! + y.amount;
      }
      for (var y in x.paid_for) {
        if (y.user == currentTripUser) paid_for_me += y.amount;
        tripUserNet[y.user] = tripUserNet[y.user]! - y.amount;
      }
    }
    setState(() {
      g_paid_by_me = paid_by_me;
      g_paid_for_me = paid_for_me;
      g_total = total;
    });
    for (var x in temp.payments) {
      t_temp.add(Transaction(false, x.created, null, x));
      if (x.by == currentTripUser) paid_by_me += x.amount;
      if (x.to == currentTripUser) paid_for_me += x.amount;
      tripUserNet[x.by] = tripUserNet[x.by]! + x.amount;
      tripUserNet[x.to] = tripUserNet[x.to]! - x.amount;
    }
    t_temp.sort((a, b) => b.date.compareTo(a.date));
    if (paid_by_me.toStringAsFixed(2) == paid_for_me.toStringAsFixed(2)) {
      setState(() {
        g_involved = "You are all settled up in this group";
        g_textColor = Color(0xfff5f5f5);
        g_free = true;
      });
    } else if (paid_by_me >= paid_for_me) {
      setState(() {
        g_involved =
            "You are owed ₹${(paid_by_me - paid_for_me).toStringAsFixed(2)} overall";
        g_textColor = mainGreen;
      });
    } else {
      setState(() {
        g_involved =
            "You owe ₹${(paid_for_me - paid_by_me).toStringAsFixed(2)} overall";
        g_textColor = mainOrange;
      });
    }
    bool deletable = true;
    for (var x in tripUserNet.entries) {
      if (roundAmount2(x.value) != 0.00) {
        deletable = false;
        break;
      }
    }
    List<Transaction> with_months = [];
    for (int i = 0; i < t_temp.length; i++) {
      if (i == 0) {
        with_months.add(Transaction(false, t_temp[i].date, null, null,
            isMonth: true,
            month: months[t_temp[i].date.month - 1] +
                " " +
                t_temp[i].date.year.toString()));
        with_months.add(t_temp[i]);
      } else {
        if (t_temp[i].date.month != t_temp[i - 1].date.month ||
            t_temp[i].date.year != t_temp[i - 1].date.year) {
          with_months.add(Transaction(false, t_temp[i].date, null, null,
              isMonth: true,
              month: months[t_temp[i].date.month - 1] +
                  " " +
                  t_temp[i].date.year.toString()));
          with_months.add(t_temp[i]);
        } else {
          with_months.add(t_temp[i]);
        }
      }
    }
    setState(() {
      loading = false;
      trip = temp;
      transactions = with_months;
      g_deletable = deletable;
    });
  }

  Future<void> onRefresh() async {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return onRefresh();
      },
      child: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              backgroundColor: Colors.grey[900],
              appBar: AppBar(
                flexibleSpace: const Opacity(
                  opacity: 0.7,
                  child: Image(
                    image: AssetImage('assets/images/trip3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      changeSetting();
                    },
                  )
                ],
              ),
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.view_list,
                overlayColor: Colors.transparent,
                animatedIconTheme: const IconThemeData(size: 22.0),
                backgroundColor: mainGreen,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.payment),
                    backgroundColor: mainGreen,
                    label: 'Add Payment',
                    labelStyle: const TextStyle(fontSize: 12),
                    onTap: () {
                      haptics();
                      addPayment();
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.receipt_outlined),
                    backgroundColor: mainGreen,
                    label: 'Add Expense ',
                    labelStyle: const TextStyle(fontSize: 12),
                    onTap: () {
                      haptics();
                      addExpense();
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: api_fetching
                        ? transactions.length == 0
                            ? 6
                            : transactions.length + 5
                        : transactions.length == 0
                            ? 5
                            : transactions.length + 4,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 30, top: 20),
                          child: Text(
                            trip!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                      if (index == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            g_involved,
                            style: TextStyle(
                              color: g_textColor,
                              fontSize: 17,
                            ),
                          ),
                        );
                      }
                      if (index == 2) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8, top: 20, bottom: 30),
                          child: Container(
                            height: 35,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    haptics();
                                    final res = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (builder) =>
                                                SettleUpBalance(
                                                  trip: trip!,
                                                  tripUserMap: tripUserMap,
                                                )));
                                    if (!mounted) return;
                                    if (res) {
                                      init();
                                    }
                                  },
                                  child: const HButton(
                                    text: 'Settle up',
                                    color: mainOrange,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    haptics();
                                    final res = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (builder) => BalancesPage(
                                                  trip: trip!,
                                                  tripUserMap: tripUserMap,
                                                )));
                                    if (!mounted) return;
                                    if (res) {
                                      init();
                                    }
                                  },
                                  child: HButton(
                                    text: 'Balances',
                                    color: Colors.grey[900] as Color,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    haptics();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (builder) => TotalsPage(
                                                  name: trip!.name,
                                                  paid_by_me: g_paid_by_me,
                                                  paid_for_me: g_paid_for_me,
                                                  total: g_total,
                                                )));
                                  },
                                  child: HButton(
                                    text: 'Totals',
                                    color: Colors.grey[900] as Color,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      export = true;
                                    });
                                    var snackBar =
                                        await excelExport(trip!, tripUserMap);
                                    setState(() {
                                      export = false;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                  child: HButton(
                                    text: export ? 'Exporting' : 'Export',
                                    color: Colors.grey[900] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (api_fetching && index == 3) {
                        return ApiLoader();
                      }
                      if ((!api_fetching &&
                              transactions.length == 0 &&
                              index == 3) ||
                          (api_fetching &&
                              transactions.length == 0 &&
                              index == 4)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              "No Expenses or Payments yet!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }
                      if ((!api_fetching &&
                              transactions.length == 0 &&
                              index == 4) ||
                          (api_fetching &&
                              transactions.length == 0 &&
                              index == 5)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              "Add Expenses or Payments to get started!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }
                      if ((!api_fetching && index == transactions.length + 3) ||
                          (api_fetching && index == transactions.length + 4)) {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Container());
                      }
                      int idx = api_fetching ? index - 4 : index - 3;
                      DateTime date = transactions[idx].date;
                      String name = transactions[idx].isExpense
                          ? transactions[idx].expense!.name
                          : "Payment";
                      String category = transactions[idx].isExpense
                          ? transactions[idx].expense!.category
                          : "general";
                      double paid_by_me = 0.00, paid_for_me = 0.00;
                      if (transactions[idx].isExpense) {
                        for (var x in transactions[idx].expense!.paid_by) {
                          if (x.user == currentTripUser) paid_by_me += x.amount;
                        }
                        for (var x in transactions[idx].expense!.paid_for) {
                          if (x.user == currentTripUser)
                            paid_for_me += x.amount;
                        }
                      } else {}
                      String involved = "";
                      String amnt = "";
                      Color textColor = Color(0xfff5f5f5);
                      if (paid_by_me == 0.00 && paid_for_me == 0.00)
                        involved = "not involved";
                      else if (paid_by_me >= paid_for_me) {
                        involved = "you owed";
                        textColor = mainGreen;
                        amnt = (paid_by_me - paid_for_me).toStringAsFixed(2);
                      } else {
                        involved = "you borrowed";
                        textColor = mainOrange;
                        amnt = (paid_for_me - paid_by_me).toStringAsFixed(2);
                      }
                      if (transactions[idx].isMonth) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                          child: Text(
                            transactions[idx].month,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        );
                      } else if (!transactions[idx].isExpense) {
                        return GestureDetector(
                          onTap: () async {
                            haptics();
                            if (!transactions[idx].isExpense) {
                              final res = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (builder) => PaymentView(
                                            payment: transactions[idx].payment!,
                                            tripUserMap: tripUserMap,
                                          )));
                              if (!mounted) return;
                              if (res) {
                                init();
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      Text(
                                        months[date.month - 1],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.asset(
                                      'assets/categories/payment.png',
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${tripUserMap[transactions[idx].payment!.by]!.name} paid ${tripUserMap[transactions[idx].payment!.to]!.name} ₹${transactions[idx].payment!.amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          overflow: TextOverflow.clip),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            haptics();
                            if (transactions[idx].isExpense) {
                              final res = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (builder) => ExpensePage(
                                            expense: transactions[idx].expense!,
                                            tripUserMap: tripUserMap,
                                            trip: trip!,
                                          )));
                              if (!mounted) return;
                              if (res == null) return;
                              if (!res['changed']) return;
                              if (res['expense'] == null) {
                                // delete expense
                                TripModel tempTrip = trip!;
                                for (int i = 0;
                                    i < tempTrip.expenses.length;
                                    i++) {
                                  if (tempTrip.expenses[i].id ==
                                      transactions[idx].expense!.id) {
                                    tempTrip.expenses.removeAt(i);
                                    break;
                                  }
                                }
                                await tempTrip.save();
                                calculate(
                                    tempTrip, Boxes.getMe().get('me')!.id);
                                return;
                              }
                              ExpenseModel expense = res['expense'];
                              setState(() {
                                transactions[idx].expense = expense;
                              });
                              TripModel tempTrip = trip!;
                              for (int i = 0;
                                  i < tempTrip.expenses.length;
                                  i++) {
                                if (tempTrip.expenses[i].id == expense.id) {
                                  tempTrip.expenses[i] = expense;
                                  break;
                                }
                              }
                              await tempTrip.save();
                              calculate(tempTrip, Boxes.getMe().get('me')!.id);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      Text(
                                        months[date.month - 1],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.asset(
                                      'assets/categories/${category}.png',
                                      height: 45.0,
                                      width: 45.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        involved,
                                        style: TextStyle(
                                            color: textColor, fontSize: 10),
                                      ),
                                      Text(
                                        amnt,
                                        style: TextStyle(
                                            color: textColor, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
    );
  }

  Future<void> addExpense() async {
    final res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (builder) => AddExpense(trip: trip!)));
    if (!mounted) return;
    if (res == null) return;
    if (!res['changed']) return;
    ExpenseModel expense = res['expense'];
    Transaction t = Transaction(true, expense.created, expense, null);
    List<Transaction> temp = transactions;
    temp.add(t);
    temp.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      transactions = temp;
    });
    TripModel tempTrip = trip!;
    tempTrip.expenses.add(expense);
    await tempTrip.save();
    calculate(tempTrip, Boxes.getMe().get('me')!.id);
  }

  Future<void> addPayment() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => ChoosePaymentBy(tripUserMap: tripUserMap)));
    if (!mounted) return;
    init();
  }

  Future<void> changeSetting() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => TripSetting(
              trip: trip!,
              free: g_free,
              currentUserID: tripUserMap[currentTripUser]!.user,
              deletable: g_deletable,
            )));
    if (!mounted) return;
    init();
  }
}

class HButton extends StatelessWidget {
  const HButton({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            border: Border.all(
              color: Color(0xffa0a0a0),
              width: 0.5,
            )),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
