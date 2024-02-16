import 'package:flutter/material.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/choosePaymentFor.dart';
import 'package:splittr/utilities/constants.dart';

class ChoosePaymentBy extends StatefulWidget {
  const ChoosePaymentBy({super.key, required this.tripUserMap});
  final Map<String, TripUser> tripUserMap;

  @override
  State<ChoosePaymentBy> createState() => _ChoosePaymentByState();
}

class _ChoosePaymentByState extends State<ChoosePaymentBy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
          title: const Text(
            'Payment From ?',
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
              haptics();
              final res = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return ChoosePaymentFor(
                  tripUserMap: widget.tripUserMap,
                  from: widget.tripUserMap.values.elementAt(index).id,
                );
              }));
              if (!mounted) return;
              Navigator.pop(context, res);
            },
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
          );
        },
      ),
    );
  }
}
