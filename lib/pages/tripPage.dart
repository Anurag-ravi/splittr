import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/addExpense.dart';
import 'package:splittr/pages/balances.dart';
import 'package:splittr/pages/expensePage.dart';
import 'package:splittr/pages/paymentPage.dart';
import 'package:splittr/pages/settleUpPage.dart';
import 'package:splittr/pages/totalPage.dart';
import 'package:splittr/pages/tripSettings.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.id});
  final String id;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool loading = true, g_free = false;
  TripModel? trip;
  List<Transaction> transactions = [];
  String currentTripUser = "";
  String g_involved = "You are all settled up in this group";
  Color g_textColor = Color(0xfff5f5f5);
  Map<String, TripUser> tripUserMap = new Map<String, TripUser>();
  double g_paid_by_me = 0.00, g_paid_for_me = 0.00, g_total = 0.00;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() {
      loading = true;
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
        for (var tu in temp.users) {
          if (tu.user == user.id) {
            setState(() {
              currentTripUser = tu.id;
            });
          }
          setState(() {
            tripUserMap.putIfAbsent(tu.id, () => tu);
          });
        }
        List<Transaction> t_temp = [];
        double paid_by_me = 0.00, paid_for_me = 0.00, total = 0.00;
        for (var x in temp.expenses) {
          total += x.amount;
          t_temp.add(Transaction(true, x.created, x, null));
          for (var y in x.paid_by) {
            if (y.user == currentTripUser) paid_by_me += y.amount;
          }
          for (var y in x.paid_for) {
            if (y.user == currentTripUser) paid_for_me += y.amount;
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
        }
        t_temp.sort((a, b) => b.date.compareTo(a.date));
        if (paid_by_me == paid_for_me) {
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
        setState(() {
          loading = false;
          trip = temp;
          transactions = t_temp;
        });

        return;
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return refresh();
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
              floatingActionButton: GestureDetector(
                onTap: () {
                  haptics();
                  addExpense();
                },
                child: Container(
                  width: 160,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: mainGreen,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Add expense',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: transactions.length + 3,
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
                                      refresh();
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
                                      refresh();
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
                                HButton(
                                  text: 'Export',
                                  color: Colors.grey[900] as Color,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      int idx = index - 3;
                      DateTime date = transactions[idx].date;
                      String name = transactions[idx].isExpense
                          ? transactions[idx].expense!.name
                          : "Payment";
                      String category = transactions[idx].isExpense
                          ? transactions[idx].expense!.category
                          : "general";
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
                      if (!transactions[idx].isExpense) {
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
                                refresh();
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
                                          )));
                              if (!mounted) return;
                              if (res) {
                                refresh();
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
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (builder) => AddExpense(trip: trip!)));
    if (!mounted) return;
    await refresh();
  }

  Future<void> changeSetting() async {
    bool updated = await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => TripSetting(
              trip: trip!,
              free: g_free,
            )));
    if (!mounted) return;
    if (!updated) return;
    await refresh();
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
