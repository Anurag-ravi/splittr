import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/payment.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class PaymentView extends StatefulWidget {
  const PaymentView(
      {super.key, required this.payment, required this.tripUserMap});
  final PaymentModel payment;
  final Map<String, TripUser> tripUserMap;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
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
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        actions: [
          loading
              ? CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    haptics();
                    handleDeletePayment();
                  },
                ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              haptics();
              handleUpdate();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(
                  'assets/categories/payment.png',
                  height: 60.0,
                  width: 60.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "${widget.tripUserMap[widget.payment.by]!.name} paid ${widget.tripUserMap[widget.payment.to]!.name}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "₹${widget.payment.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Added on ${months[widget.payment.created.month - 1]} ${widget.payment.created.day}, ${widget.payment.created.year} at ${widget.payment.created.hour}:${widget.payment.created.minute}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void handleDeletePayment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will permanently delete this Payment'),
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
        "${url!}/payment/${widget.payment.id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        context);
    setState(() {
      loading = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        const snackBar = SnackBar(
          content: Text('Payment deleted'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context, true);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message'] ?? 'An error occurred'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> handleUpdate() async {
    final res =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PaymentPage(
        from: widget.payment.by,
        to: widget.payment.to,
        amount: widget.payment.amount,
        payment_id: widget.payment.id,
        updating: true,
        tripUserMap: widget.tripUserMap,
      );
    }));
    if (!mounted) {
      return;
    }
    if (res != null && res) {
      Navigator.pop(context, true);
    }
  }
}
