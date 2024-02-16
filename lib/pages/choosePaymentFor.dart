import 'package:flutter/material.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/payment.dart';
import 'package:splittr/utilities/constants.dart';

class ChoosePaymentFor extends StatefulWidget {
  const ChoosePaymentFor(
      {super.key, required this.tripUserMap, required this.from});
  final Map<String, TripUser> tripUserMap;
  final String from;

  @override
  State<ChoosePaymentFor> createState() => _ChoosePaymentForState();
}

class _ChoosePaymentForState extends State<ChoosePaymentFor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
          title: const Text(
            'Payment To ?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false);
            },
          )),
      body: ListView.builder(
        itemCount: widget.tripUserMap.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              if(widget.tripUserMap.values.elementAt(index).id == widget.from) return;
              haptics();
              final res = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return PaymentPage(
                    from: widget.from,
                    to: widget.tripUserMap.values.elementAt(index).id,
                    amount: 0,
                    tripUserMap: widget.tripUserMap);
              }));
              if (!mounted) return;
              Navigator.pop(context, res);
            },
            child: Opacity(
              opacity: widget.tripUserMap.values.elementAt(index).id == widget.from ? 0.5 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/profile/${widget.tripUserMap.values.elementAt(index).dp}.png',
                        height: 40.0,
                        width: 40.0,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.tripUserMap.values.elementAt(index).name,
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
