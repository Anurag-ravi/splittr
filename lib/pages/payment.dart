import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.tripUserMap,
    this.updating = false,
    this.payment_id = "",
    this.created = null,
  });
  final String from;
  final String to;
  final double amount;
  final Map<String, TripUser> tripUserMap;
  final bool updating;
  final String payment_id;
  final DateTime? created;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool responseLoading = false;
  TextEditingController amountController = TextEditingController();
  String amount = "0.00";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      if (widget.amount.toStringAsFixed(2) != "0.00") {
        amount = widget.amount.toStringAsFixed(2);
        amountController.text = amount;
      } else {
        amount = "";
        amountController.text = amount;
      }
      if (widget.updating && widget.created != null) {
        selectedDate = widget.created!;
      }
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.updating ? 'Update Payment' : 'Record Payment',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        actions: [
          IconButton(
            icon: responseLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 3,
                  )
                : const Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
            onPressed: () {
              haptics();
              if (widget.updating) {
                updatePayment();
              } else {
                createPayment();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                        "assets/profile/${widget.tripUserMap[widget.from]!.dp}.png"),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.white,
                          size: 30,
                        )),
                    Container(
                      height: 40,
                      width: 40,
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
                SizedBox(
                  width: 10,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                          "assets/profile/${widget.tripUserMap[widget.to]!.dp}.png"),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.tripUserMap[widget.from]!.name.trim()} pays ${widget.tripUserMap[widget.to]!.name.trim()}",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 1,
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
                        height: 40,
                        width: 40,
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
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: amountController,
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
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.grey[900],
                      filled: true,
                      contentPadding: EdgeInsets.only(),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    haptics();
                    showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(0),
                      lastDate: DateTime.now(),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            selectedDate.hour,
                            selectedDate.minute,
                          ).toLocal();
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      // width: 80,
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        // only bottom border
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffa0a0a0),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.access_time_outlined,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    haptics();
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    ).then((time) {
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            time.hour,
                            time.minute,
                          ).toLocal();
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      // width: 80,
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xffa0a0a0),
                              width: 0.5,
                            ),
                          )),
                      child: Center(
                        child: Text(
                          getTimeString(selectedDate),
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

  String getTimeString(DateTime date) {
    int hour = date.hour;
    if (hour > 12) {
      hour -= 12;
    }
    if (hour == 0) hour = 12;
    String hr = hour < 10 ? "0$hour" : hour.toString();
    String min = date.minute < 10 ? "0${date.minute}" : date.minute.toString();
    String ampm = date.hour > 12 ? "PM" : "AM";
    return "$hr:$min $ampm";
  }

  void createPayment() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      responseLoading = true;
    });
    bool res2 = amountController.text.isNotEmpty;
    if (!res2) {
      setState(() {
        responseLoading = false;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/payment/new",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({
          "by": widget.from,
          "to": widget.to,
          "amount": double.parse(amount),
          "trip_id": widget.tripUserMap[widget.from]!.trip,
          "created": selectedDate.toIso8601String() + "+05:30",
        }),
        prefs,
        context);
    setState(() {
      responseLoading = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        const snackBar = SnackBar(
          content: Text('Payments added'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        PaymentModel payment = PaymentModel.fromJson(data['data']);
        TripModel trip = Boxes.getTrips().get(payment.trip)!;
        trip.payments.add(payment);
        await trip.save();
        Navigator.pop(context, true);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updatePayment() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      responseLoading = true;
    });
    bool res2 = amountController.text.isNotEmpty;
    if (!res2) {
      setState(() {
        responseLoading = false;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/payment/${widget.payment_id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({
          "amount": double.parse(amount),
          "created": selectedDate.toIso8601String() + "+05:30",
        }),
        prefs,
        context);
    setState(() {
      responseLoading = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        const snackBar = SnackBar(
          content: Text('Payments Updated'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        PaymentModel payment = PaymentModel.fromJson(data['data']);
        TripModel trip = Boxes.getTrips().get(payment.trip)!;
        trip.payments.removeWhere((element) => element.id == payment.id);
        trip.payments.add(payment);
        await trip.save();
        Navigator.pop(context, true);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
