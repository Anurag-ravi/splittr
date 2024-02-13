import 'package:flutter/material.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/payment.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/settleUp.dart';

class Bal {
  String user;
  String from;
  String to;
  double amount;
  bool isPositive;
  bool isSettled;
  bool isMainEntry;
  Bal(this.user, this.from, this.to, this.amount, this.isPositive,
      this.isSettled, this.isMainEntry);

  @override
  String toString() {
    return 'Bal{user: $user, from: $from, to: $to, amount: $amount, isPositive: $isPositive, isSettled: $isSettled, isMainEntry: $isMainEntry}';
  }
}

class BalancesPage extends StatefulWidget {
  const BalancesPage(
      {super.key, required this.trip, required this.tripUserMap});
  final TripModel trip;
  final Map<String, TripUser> tripUserMap;

  @override
  State<BalancesPage> createState() => _BalancesPageState();
}

class _BalancesPageState extends State<BalancesPage> {
  List<Bal> transactions = [];
  List<bool> isExpanded = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var temp = settleUp(widget.trip);
    setState(() {
      for (var x in temp) {
        String name = widget.tripUserMap[x.user]!.name;
        if (x.amount == 0.0) {
          name += " is settled up";
          transactions.add(Bal(name, x.user, "", 0.0, true, true, true));
          isExpanded.add(false);
        } else {
          name += x.isPositive ? " gets back" : " owes";
          transactions
              .add(Bal(name, x.user, "", x.amount, x.isPositive, false, true));
          isExpanded.add(false);
        }
        for (var entry in x.paid) {
          String from = x.isPositive ? entry.user : x.user;
          String to = x.isPositive ? x.user : entry.user;
          String name = widget.tripUserMap[from]!.name;
          name += " owes ";
          transactions.add(
              Bal(name, from, to, entry.amount, x.isPositive, false, false));
          isExpanded.add(false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Balances", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context,false);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          if (transactions[index].isMainEntry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  int i = index;
                  isExpanded[i] = !isExpanded[i];
                  i++;
                  while (
                      i < transactions.length && !transactions[i].isMainEntry) {
                    isExpanded[i] = !isExpanded[i];
                    i++;
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.only(left: 10, top: 25),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            child: Image.asset(
                              "assets/profile/${widget.tripUserMap[transactions[index].from]!.dp}.png",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: RichText(
                        overflow: TextOverflow.clip,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: transactions[index].user,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            transactions[index].isSettled
                                ? TextSpan()
                                : TextSpan(
                                    text:
                                        " ₹${transactions[index].amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: transactions[index].isPositive
                                          ? mainGreen
                                          : mainOrange,
                                      fontSize: 17,
                                    ),
                                  ),
                            transactions[index].isSettled
                                ? TextSpan()
                                : TextSpan(
                                    text: " in total",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: transactions[index].isSettled
                          ? Icon(
                              Icons.check_circle,
                              color: mainGreen,
                              size: 17,
                            )
                          : Icon(
                              !isExpanded[index]
                                  ? Icons.keyboard_arrow_down_outlined
                                  : Icons.keyboard_arrow_up_outlined,
                              color: Colors.white,
                              size: 25,
                            ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return isExpanded[index]
                ? Container(
                    padding: EdgeInsets.only(left: 50, top: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    child: Image.asset(
                                      "assets/profile/${widget.tripUserMap[transactions[index].from]!.dp}.png",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: RichText(
                                overflow: TextOverflow.clip,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: transactions[index].user,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "₹${transactions[index].amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: transactions[index].isPositive
                                            ? mainGreen
                                            : mainOrange,
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          " to ${widget.tripUserMap[transactions[index].to]!.name}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mainGreen,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Remind...",
                                style: TextStyle(
                                  color: mainGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                haptics();
                                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(
                                  tripUserMap: widget.tripUserMap,
                                  from: transactions[index].from,
                                  to: transactions[index].to,
                                  amount: transactions[index].amount,
                                )));
                                if(!mounted) return;
                                if(res){
                                  Navigator.pop(context,true);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: mainGreen,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "Settle up",
                                  style: TextStyle(
                                    color: mainGreen,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container();
          }
        },
      ),
    );
  }
}
