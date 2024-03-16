import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/addExpense.dart';
import 'package:splittr/utilities/request.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage(
      {super.key,
      required this.expense,
      required this.trip,
      required this.tripUserMap});
  final ExpenseModel expense;
  final Map<String, TripUser> tripUserMap;
  final TripModel trip;

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
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
  List<String> nets = [];
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() {
    Map<TripUser, double> paid = {}, owed = {};
    for (var x in widget.expense.paid_by) {
      paid[widget.tripUserMap[x.user]!] = x.amount;
    }
    for (var x in widget.expense.paid_for) {
      owed[widget.tripUserMap[x.user]!] = x.amount;
    }
    List<String> t1 = [], t2 = [];
    widget.tripUserMap.forEach((id, tripuser) {
      String a = tripuser.name.trim();
      bool involved = false;
      bool comesFirst = false;
      if (paid.containsKey(tripuser)) {
        involved = true;
        comesFirst = true;
        a += " paid ₹${paid[tripuser]!.toStringAsFixed(2)}";
      }
      if (owed.containsKey(tripuser)) {
        if (involved) a += " and";
        involved = true;
        a += " owed ₹${owed[tripuser]!.toStringAsFixed(2)}";
      }
      if (involved) {
        if (comesFirst) {
          t1.add(a);
        } else {
          t2.add(a);
        }
      }
    });
    setState(() {
      nets.addAll(t1);
      nets.addAll(t2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.pink[50],
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () {
                    handleDelete();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: () {
                    handleEdit();
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: nets.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(
                            'assets/categories/${widget.expense.category}.png',
                            height: 45.0,
                            width: 45.0,
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.expense.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              "₹ ${widget.expense.amount..toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                if (index == 1) {
                  int hour = widget.expense.created.hour;
                  String ampm = "AM";
                  if (hour > 12) {
                    hour -= 12;
                    ampm = "PM";
                  }
                  if(hour == 0) hour = 12;
                  String hr = hour < 10 ? "0$hour" : "$hour";
                  String min = widget.expense.created.minute < 10
                      ? "0${widget.expense.created.minute}"
                      : "${widget.expense.created.minute}";
                  return Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Text(
                      "Added on ${months[widget.expense.created.month - 1]} ${widget.expense.created.day}, ${widget.expense.created.year} at ${hr}:${min} $ampm",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis),
                    ),
                  );
                }
                if (index == 2) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/profile/${widget.tripUserMap[widget.expense.paid_by[0].user]!.dp}.png',
                            height: 50.0,
                            width: 50.0,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.expense.paid_by.length == 1
                              ? "${widget.tripUserMap[widget.expense.paid_by[0].user]!.name} paid ₹${widget.expense.amount}"
                              : "${widget.expense.paid_by.length} people paid ₹${widget.expense.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                int idx = index - 3;
                return Padding(
                  padding: const EdgeInsets.only(left: 75, top: 10),
                  child: Text(
                    "${nets[idx]}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis),
                  ),
                );
              },
            ),
          );
  }

  Future<void> handleDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will permanently delete this data'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == null || !result) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    setState(() {
      loading = true;
    });
    var data = await deleteRequest(
        "${url!}/expense/${widget.expense.id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        context);
    if (data != null) {
      if (data['status'] == 200) {
        setState(() {
          loading = false;
        });
        const snackBar = SnackBar(
          content: Text('Expense deleted'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context, true);
        return;
      }
    }
    setState(() {
      loading = false;
    });
  }

  void handleEdit() async {
    final res =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddExpense(
        trip: widget.trip,
        updating: true,
        expense: widget.expense,
      );
    }));
    if (res != null && res) {
      Navigator.pop(context, true);
    }
  }
}
