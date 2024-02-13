import 'package:flutter/material.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/payment.dart';
import 'package:splittr/utilities/settleUp.dart';

class SettleUpBalance extends StatefulWidget {
  const SettleUpBalance(
      {super.key, required this.trip, required this.tripUserMap});
  final TripModel trip;
  final Map<String, TripUser> tripUserMap;

  @override
  State<SettleUpBalance> createState() => _SettleUpBalanceState();
}

class _SettleUpBalanceState extends State<SettleUpBalance> {
  List<Triad> balances = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      balances = settleUp(widget.trip, flag: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Select a balance to settle",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: balances.length == 0 ? Center(
        child: Text(
          "No balances to settle",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      )
      : ListView.builder(
        itemCount: balances.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              final res = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return PaymentPage(
                  from: balances[index].from,
                  to: balances[index].to,
                  amount: balances[index].amount,
                  tripUserMap: widget.tripUserMap,
                );
              }));
              if (!mounted) return;
              if (res != null && res) {
                Navigator.pop(context, true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                            "assets/profile/${widget.tripUserMap[balances[index].from]!.dp}.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 13,
                    child: RichText(
                      overflow: TextOverflow.clip,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                widget.tripUserMap[balances[index].from]!.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text:
                                " pays ₹${balances[index].amount.toStringAsFixed(2)} to ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: widget.tripUserMap[balances[index].to]!.name,
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
            ),
          );
        },
      ),
    );
  }
}
