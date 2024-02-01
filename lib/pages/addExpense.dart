import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/chooseCategory.dart';
import 'package:splittr/pages/choosePaidBy.dart';
import 'package:splittr/pages/choosePaidFor.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class AddExpense extends StatefulWidget {
  AddExpense({super.key, required this.trip});
  final TripModel trip;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  String category = "general";
  TextEditingController nameController = TextEditingController();
  String amount = "0.00";
  String currentTripUser = "";
  late UserModel user;
  bool loading = true;
  bool responseLoading = false;
  bool nameValid = true;
  splitTypeEnum splitType = splitTypeEnum.equal;
  List<By> paid_by = [];
  List<By> paid_for = [];
  Map<String, TripUser> tripUserMap = new Map<String, TripUser>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
    });
    List<By> temp = [], temp2 = [];
    for (var tu in widget.trip.users) {
      if (tu.user == user.id) {
        temp.add(By(tu.id, 0.00, 0.00));
        setState(() {
          currentTripUser = tu.id;
        });
      }
      temp2.add(By(tu.id, 0.00, 0.00));
      setState(() {
        tripUserMap.putIfAbsent(tu.id, () => tu);
      });
    }
    setState(() {
      paid_by = temp;
      paid_for = temp2;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                'Add expense',
                style: TextStyle(color: Colors.white),
              ),
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
                  icon: responseLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 3,
                        )
                      : Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                  onPressed: () {
                    createExpense();
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'With you and: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(
                              color: Color(0xffa0a0a0),
                              width: 0.5,
                            )),
                        child: Center(
                          child: Text(
                            'All of ${widget.trip.name}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            SystemSound.play(SystemSoundType.click);
                            getCategory(category);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Image.asset(
                                  'assets/categories/${category}.png',
                                  height: 45.0,
                                  width: 45.0,
                                ),
                              ),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    border: Border.all(
                                      color: mainGreen,
                                      width: 1,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TextField(
                            cursorColor: mainGreen,
                            style: TextStyle(color: Colors.white),
                            onChanged: (text) {
                              setState(() {
                                nameValid = true;
                              });
                            },
                            controller: nameController,
                            decoration: nameValid
                                ? InputDecoration(
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
                                    labelText: 'Expense Name',
                                    fillColor: Colors.grey[900],
                                    filled: true,
                                  )
                                : const InputDecoration(
                                    errorText: 'Please Enter a valid Name'),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            getCategory(category);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: Icon(
                                    Icons.currency_rupee_outlined,
                                    color: Colors.white,
                                  )),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TextField(
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
                                  amount = input;
                                });
                              } else {
                                setState(() {
                                  amount = "0.00";
                                });
                              }
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
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Paid by ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          SystemSound.play(SystemSoundType.click);
                          changePaidBy();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                border: Border.all(
                                  color: Color(0xffa0a0a0),
                                  width: 0.5,
                                )),
                            child: Center(
                              child: Text(
                                paid_by.length == 1
                                    ? paid_by[0].user == currentTripUser
                                        ? 'you'
                                        : tripUserMap[paid_by[0].user]!.name
                                    : '2+ people',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        " and split  ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          SystemSound.play(SystemSoundType.click);
                          changePaidfor();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                border: Border.all(
                                  color: Color(0xffa0a0a0),
                                  width: 0.5,
                                )),
                            child: Center(
                              child: Text(
                                splitType == splitTypeEnum.equal
                                    ? 'equally'
                                    : splitType == splitTypeEnum.unequal
                                        ? 'unequally'
                                        : splitType == splitTypeEnum.shares
                                            ? 'shares'
                                            : 'percent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }

  Future<void> getCategory(String cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseCategory(categ: category)),
    );

    if (!mounted) return;
    setState(() {
      category = result;
    });
  }

  void createExpense() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      loading = true;
    });
    bool res2 = nameController.text.isNotEmpty;
    if (!res2) {
      setState(() {
        loading = false;
        nameValid = false;
      });
      return;
    }

    adjustBalanceIfSplitEqually();
    adjustPaidIfIndividual();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    List<Map<String, dynamic>> paid_by_json = [];
    List<Map<String, dynamic>> paid_for_json = [];
    paid_by.forEach((paid_by_item) {
      paid_by_json.add(paid_by_item.toJson());
    });
    paid_for.forEach((paid_for_item) {
      paid_for_json.add(paid_for_item.toJson());
    });
    var data = await postRequest(
        "${url!}/expense/new",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({
          "trip": widget.trip.id,
          "name": nameController.text,
          "amount": double.parse(amount),
          "category": category,
          "split_type": splitType.name,
          "paid_by": paid_by_json,
          "paid_for": paid_for_json,
        }),
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        const snackBar = SnackBar(
          content: Text('Expense added'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      loading = false;
    });
  }

  void adjustBalanceIfSplitEqually() {
    if (splitType != splitTypeEnum.equal) return;
    List<By> temp = paid_for;
    double amnt = double.parse(amount);
    int participants = widget.trip.users.length;
    String x = (amnt / participants).toStringAsFixed(20);
    double perAmnt = double.parse(x.substring(0, x.length - 18));
    for (int i = 0; i < temp.length; i++) {
      temp[i].amount = perAmnt;
    }
    double diff = amnt - (perAmnt * participants);
    int i = 0;
    while (diff >= 0.01) {
      temp[i % temp.length].amount += 0.01;
      i++;
      diff -= 0.01;
    }
    setState(() {
      paid_for = temp;
    });
  }

  void adjustPaidIfIndividual() {
    List<By> temp = paid_by;
    if (temp.length != 1) return;
    temp[0].amount = double.parse(amount);
    setState(() {
      paid_by = temp;
    });
  }

  Future<void> changePaidBy() async {
    List<By> result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChoosePaidBy(
                tripUserMap: tripUserMap,
                paid_by: paid_by,
                amount: double.parse(amount),
              )),
    );
    if (!mounted) return;
    print(result);
    setState(() {
      paid_by = result;
    });
  }

  Future<void> changePaidfor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChoosePaidFor(
                tripUserMap: tripUserMap,
                paid_for: paid_for,
                amount: double.parse(amount),
                splitType: splitType,
              )),
    );
    if (!mounted) return;
    print(result);
    setState(() {
      splitType = result['type'];
      paid_for = result['paid_for'];
    });
    // setState(() {
    //   paid_by = result;
    // });
  }
}
