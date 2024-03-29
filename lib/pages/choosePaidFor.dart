import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';

class ChoosePaidFor extends StatefulWidget {
  const ChoosePaidFor(
      {super.key,
      required this.tripUserMap,
      required this.paid_for,
      required this.amount,
      required this.splitType});

  final Map<String, TripUser> tripUserMap;
  final List<By> paid_for;
  final double amount;
  final splitTypeEnum splitType;

  @override
  State<ChoosePaidFor> createState() => _ChoosePaidForState();
}

class _ChoosePaidForState extends State<ChoosePaidFor>
    with TickerProviderStateMixin {
  List<TripUser> users = [];
  List<ByEqual> paid_for_equally = [];
  List<By> paid_for_unequally = [];
  List<By> paid_for_percent = [];
  List<ByShare> paid_for_share = [];
  double total = 0.0;
  splitTypeEnum splitType = splitTypeEnum.equal;
  late TabController _tabController;
  List<TextEditingController> controllers = [];
  List<TextEditingController> shareControllers = [];
  int tab_index = 0;

  // equal state
  bool all_involved = false;
  int person = 0;

  // share state
  int total_share = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      users = widget.tripUserMap.values.toList();
      splitType = widget.splitType;
      _tabController = TabController(length: 3, vsync: this);
      _tabController.animateTo(widget.splitType.index);
      _tabController.addListener(() {
        setState(() {
          tab_index = _tabController.index;
        });
      });
      tab_index = widget.splitType.index;
    });
    setState(() {
      paid_for_equally = users.map((e) => ByEqual(e.id, false)).toList();
      paid_for_unequally = users.map((e) => By(e.id, 0.00, 0.00)).toList();
      paid_for_percent = users.map((e) => By(e.id, 0.00, 0.00)).toList();
      paid_for_share = users.map((e) => ByShare(e.id, 0)).toList();

      controllers = users.map((e) {
        return TextEditingController(text: "");
      }).toList();

      shareControllers = users.map((e) {
        return TextEditingController(text: "");
      }).toList();

      if (splitType == splitTypeEnum.equal) {
        for (int i = 0; i < paid_for_equally.length; i++) {
          for (int j = 0; j < widget.paid_for.length; j++) {
            if (paid_for_equally[i].user == widget.paid_for[j].user) {
              paid_for_equally[i].involved = true;
            }
          }
          all_involved = widget.paid_for.length == users.length;
          person = widget.paid_for.length;
        }
      }
      if (splitType == splitTypeEnum.unequal) {
        for (int i = 0; i < paid_for_unequally.length; i++) {
          for (int j = 0; j < widget.paid_for.length; j++) {
            if (paid_for_unequally[i].user == widget.paid_for[j].user) {
              paid_for_unequally[i].amount = widget.paid_for[j].amount;
              total += widget.paid_for[j].amount;
            }
          }
        }
        controllers = paid_for_unequally.map((e) {
          if (e.amount.toStringAsFixed(2) != "0.00") {
            return TextEditingController(text: e.amount.toStringAsFixed(2));
          } else {
            return TextEditingController(text: "");
          }
        }).toList();
      }
      if (splitType == splitTypeEnum.shares) {
        for (int i = 0; i < paid_for_share.length; i++) {
          for (int j = 0; j < widget.paid_for.length; j++) {
            if (paid_for_share[i].user == widget.paid_for[j].user) {
              paid_for_share[i].share =
                  widget.paid_for[j].share_or_percent.toInt();
              total_share += widget.paid_for[j].share_or_percent.toInt();
            }
          }
        }
        shareControllers = paid_for_share.map((e) {
          if (e.share != 0) {
            return TextEditingController(text: e.share.toString());
          } else {
            return TextEditingController(text: "");
          }
        }).toList();
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
          'Adjust split',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context,
                {'type': widget.splitType, 'paid_for': widget.paid_for});
          },
        ),
        actions: [
          (tab_index == 0 && person == 0) ||
                  (tab_index == 1 &&
                      total.toStringAsFixed(2) !=
                          widget.amount.toStringAsFixed(2)) ||
                  (tab_index == 2 && total_share == 0)
              ? Container()
              : IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    List<By> temp = [];
                    if (_tabController.index == 0) {
                      for (var x in paid_for_equally) {
                        if (x.involved) temp.add(By(x.user, 0.00, 0.00));
                      }
                      Navigator.pop(context,
                          {'type': splitTypeEnum.equal, 'paid_for': temp});
                    }
                    if (_tabController.index == 1) {
                      if (widget.amount != total) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Amounts do not add up to ${widget.amount}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                        return;
                      }
                      for (var x in paid_for_unequally) {
                        if (x.amount > 0.00)
                          temp.add(By(x.user, x.amount, 0.00));
                      }
                      Navigator.pop(context,
                          {'type': splitTypeEnum.unequal, 'paid_for': temp});
                    }
                    if (_tabController.index == 2) {
                      if (total_share == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Shares cannot be 0',
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                        return;
                      }
                      double tot = 0.00;
                      for (var x in paid_for_share) {
                        if (x.share > 0) {
                          double c_amnt = roundAmount(
                              (widget.amount * x.share) / (total_share + 0.00));
                          tot += c_amnt;
                          temp.add(By(x.user, c_amnt, x.share + 0.00));
                        }
                      }
                      double diff = double.parse(
                          (widget.amount - tot).toStringAsFixed(2));
                      int i = 0;
                      while (diff >= 0.01) {
                        temp[i % (temp.length)].amount = double.parse(
                            (temp[i % (temp.length)].amount + 0.01)
                                .toStringAsFixed(2));
                        diff -= 0.01;
                        i++;
                      }
                      Navigator.pop(context,
                          {'type': splitTypeEnum.shares, 'paid_for': temp});
                    }
                  },
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: mainGreen,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              child: Text(
                'Equally',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Unequally',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            // Tab(
            //   child: Text(
            //     'Percent',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
            Tab(
              child: Text(
                'Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: _tabController,
        children: [
          // equal
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        person > 0
                            ? '₹${roundAmountStr(widget.amount / person)} per person'
                            : 'You must select at least 1 person',
                        style: TextStyle(
                          color: person > 0 ? Colors.white : Colors.redAccent,
                          fontSize: person > 0 ? 15 : 12,
                        ),
                      ),
                      Text(
                        '(${person} person)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'All ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Checkbox(
                        value: all_involved,
                        onChanged: (value) {
                          setState(() {
                            paid_for_equally = paid_for_equally
                                .map((e) => ByEqual(e.user, !all_involved))
                                .toList();
                            person = all_involved ? 0 : users.length;
                          });
                          setState(() {
                            all_involved = !all_involved;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      paid_for_equally[index].involved =
                          !paid_for_equally[index].involved;
                    });
                    int c = 0;
                    for (var x in paid_for_equally) {
                      if (!x.involved) c++;
                    }
                    setState(() {
                      all_involved = c == 0;
                      person = users.length - c;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
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
                            flex: 7,
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
                            flex: 1,
                            child: Checkbox(
                              value: paid_for_equally[index].involved,
                              onChanged: (value) {
                                setState(() {
                                  paid_for_equally[index].involved =
                                      !paid_for_equally[index].involved;
                                });
                                int c = 0;
                                for (var x in paid_for_equally) {
                                  if (!x.involved) c++;
                                }
                                setState(() {
                                  all_involved = c == 0;
                                  person = users.length - c;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // unequal
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: Container(
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
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
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
                                  paid_for_unequally[index].amount =
                                      double.parse(input);
                                });
                              } else {
                                setState(() {
                                  paid_for_unequally[index].amount = 0.00;
                                });
                              }
                              double value = 0;
                              for (var x in paid_for_unequally)
                                value += x.amount;
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
          ),
          // share
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: Container(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${total_share} total shares',
                    style: TextStyle(
                        color: total_share != 0.00
                            ? Colors.white
                            : Colors.redAccent,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                users[index].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                total_share == 0
                                    ? '₹0.00'
                                    : '₹${roundAmountStr((widget.amount * paid_for_share[index].share) / (total_share + 0.00))}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded(child: Container()),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 30,
                          child: TextField(
                            controller: shareControllers[index],
                            keyboardType: TextInputType.numberWithOptions(
                              signed: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+')),
                            ],
                            cursorColor: mainGreen,
                            style: TextStyle(color: Colors.white),
                            onChanged: (input) {
                              if (input.isNotEmpty) {
                                setState(() {
                                  paid_for_share[index].share =
                                      int.parse(input);
                                });
                              } else {
                                setState(() {
                                  paid_for_share[index].share = 0;
                                });
                              }
                              int value = 0;
                              for (var x in paid_for_share) value += x.share;
                              setState(() {
                                total_share = value;
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
                              labelText: '0',
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
          ),
        ],
      ),
    );
  }
}
