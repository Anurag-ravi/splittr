import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';

class ChoosePaidBy extends StatefulWidget {
  const ChoosePaidBy(
      {super.key,
      required this.tripUserMap,
      required this.paid_by,
      required this.amount});

  final Map<String, TripUser> tripUserMap;
  final List<By> paid_by;
  final double amount;

  @override
  State<ChoosePaidBy> createState() => _ChoosePaidByState();
}

class _ChoosePaidByState extends State<ChoosePaidBy> {
  List<TripUser> users = [];
  List<By> paid_by = [], multiple_paid_by = [];
  List<TextEditingController> controllers = [];
  bool single_paid = true;
  String currentPaidUser = "";
  double total = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      users = widget.tripUserMap.values.toList();
      paid_by = widget.paid_by;
      single_paid = widget.paid_by.length == 1;
      currentPaidUser = widget.paid_by[0].user;
      controllers = widget.tripUserMap.values
          .toList()
          .map((e) => TextEditingController(text: ""))
          .toList();
    });
    setState(() {
      multiple_paid_by = users.map((e) {
        bool paid = false;
        double amnt = 0.00;
        for (var i = 0; i < paid_by.length; i++) {
          if (paid_by[i].user == e.id && paid_by[i].amount > 0.00) {
            paid = true;
            amnt = paid_by[i].amount;
            total += amnt;
            break;
          }
        }
        return By(e.id, paid ? amnt : 0.00, 0.00);
      }).toList();
    });
    setState(() {
      for (int i = 0; i < multiple_paid_by.length; i++) {
        if (multiple_paid_by[i].amount > 0.00)
          controllers[i].text = multiple_paid_by[i].amount.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Who paid?',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, widget.paid_by);
          },
        ),
        actions: [
          single_paid
              ? Container()
              : IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.amount != total) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Amounts do not add up to ${widget.amount}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ));
                      return;
                    }
                    List<By> temp = [];
                    for (var e in multiple_paid_by) {
                      if (e.amount > 0.00) {
                        temp.add(e);
                      }
                    }
                    Navigator.pop(context, temp);
                  },
                ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: single_paid
          ? Container(
              height: 0,
            )
          : Container(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹${roundAmountStr(total)} of ₹${roundAmountStr(widget.amount)}',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    widget.amount - total >= 0.00
                        ? '₹${roundAmountStr(widget.amount - total)} left'
                        : '₹${roundAmountStr(total - widget.amount)} over',
                    style: TextStyle(
                        color: widget.amount - total >= 0.00
                            ? Colors.white
                            : Colors.redAccent,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
      body: single_paid
          ? ListView.builder(
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                if (index == users.length)
                  return GestureDetector(
                    onTap: () {
                      haptics();
                      setState(() {
                        single_paid = false;
                      });
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Text(
                        'Multiple people',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                return GestureDetector(
                  onTap: () {
                    haptics();
                    List<By> temp = [];
                    temp.add(By(users[index].id, widget.amount, 0.00));
                    Navigator.pop(context, temp);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/profile/${users[index].dp}.png',
                            height: 40.0,
                            width: 40.0,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          users[index].name,
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(child: Container()),
                        currentPaidUser == users[index].id
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                );
              })
          : ListView.builder(
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                if (index == users.length)
                  return GestureDetector(
                    onTap: () {
                      haptics();
                      setState(() {
                        single_paid = true;
                      });
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Text(
                        'Single person paid',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/profile/${users[index].dp}.png',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            users[index].name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      // Expanded(child: Container()),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 30,
                          child: TextField(
                            controller: controllers[index],
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            cursorColor: mainGreen,
                            style: TextStyle(color: Colors.white),
                            onChanged: (input) {
                              if (input.isNotEmpty) {
                                setState(() {
                                  multiple_paid_by[index].amount =
                                      double.parse(input);
                                });
                              } else {
                                setState(() {
                                  multiple_paid_by[index].amount = 0.00;
                                });
                              }
                              double value = 0;
                              for (var x in multiple_paid_by) value += x.amount;
                              setState(() {
                                total = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: mainGreen,
                                ),
                              ),
                              labelText: '0.00',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
