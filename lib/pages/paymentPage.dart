import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/comment.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/payment.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/widgets/comment_tile.dart';
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
  final List months = [
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
  List<CommentModel> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool loading = false;
  bool sendingComment = false;
  String? myUserId;

  @override
  void initState() {
    super.initState();
    final me = Boxes.getMe().get('me');
    myUserId = me?.id;
    comments = List<CommentModel>.from(widget.payment.comments ?? []);
    refreshComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> refreshComments() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    final data = await getRequest(
        "$url/comment/payment/${widget.payment.id}",
        {'Accept': 'application/json', 'Authorization': token!},
        prefs,
        context);
    if (data != null && data['status'] == 200) {
      final fetched =
          (data['data'] as List).map((e) => CommentModel.fromJson(e)).toList();
      widget.payment.comments = fetched;
      final box = Boxes.getPayments();
      await box.put(widget.payment.id, widget.payment);
      if (mounted) {
        setState(() {
          comments = fetched;
        });
      }
    }
  }

  Future<void> postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => sendingComment = true);
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    final data = await postRequest(
        "$url/comment/new",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({
          'entity_type': 'payment',
          'entity_id': widget.payment.id,
          'trip': widget.payment.trip,
          'title':
              'Comment added on payment of ₹${widget.payment.amount.toStringAsFixed(2)} from ${widget.tripUserMap[widget.payment.by]!.name} to ${widget.tripUserMap[widget.payment.to]!.name}',
          'body': text,
        }),
        prefs,
        context);
    setState(() => sendingComment = false);
    if (data != null && data['status'] == 200) {
      _commentController.clear();
      await refreshComments();
    }
  }

  Future<void> deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    final data = await deleteRequest(
        "$url/comment/$commentId",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        context);
    if (data != null && data['status'] == 200) {
      widget.payment.comments?.removeWhere((c) => c.id == commentId);
      final box = Boxes.getPayments();
      await box.put(widget.payment.id, widget.payment);
      if (mounted) {
        setState(() {
          comments.removeWhere((c) => c.id == commentId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int hour = widget.payment.created.hour;
    String ampm = "AM";
    if (hour > 12) {
      hour -= 12;
      ampm = "PM";
    }
    if (hour == 0) hour = 12;
    String hr = hour < 10 ? "0$hour" : "$hour";
    String min = widget.payment.created.minute < 10
        ? "0${widget.payment.created.minute}"
        : "${widget.payment.created.minute}";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {
                    haptics();
                    handleDeletePayment();
                  },
                ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              haptics();
              handleUpdate();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshComments,
              child: ListView(children: [
                Column(
                  children: [
                    const SizedBox(height: 50),
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
                    const SizedBox(height: 20),
                    Text(
                      "${widget.tripUserMap[widget.payment.by]!.name} paid ${widget.tripUserMap[widget.payment.to]!.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "₹${widget.payment.amount.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Added on ${months[widget.payment.created.month - 1]} ${widget.payment.created.day}, ${widget.payment.created.year} at $hr:$min $ampm",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    // Activity section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Row(
                        children: [
                          const Text("Activity",
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                ...comments.map((comment) => CommentTile(
                      comment: comment,
                      tripUserMap: widget.tripUserMap,
                      myUserId: myUserId,
                      onDelete: () => deleteComment(comment.id),
                    )),
              ]),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => postComment(),
            ),
          ),
          const SizedBox(width: 8),
          sendingComment
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.greenAccent),
                  onPressed: postComment,
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
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (result == null || !result) return;
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    setState(() => loading = true);
    final data = await deleteRequest(
        "${url!}/payment/${widget.payment.id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        context);
    setState(() => loading = false);
    if (data != null && data['status'] == 200) {
      const snackBar = SnackBar(content: Text('Payment deleted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      TripModel trip = Boxes.getTrips().get(widget.payment.trip)!;
      trip.payments.removeWhere((element) => element.id == widget.payment.id);
      await trip.save();
      Navigator.pop(context, true);
      return;
    }
    final snackBar =
        SnackBar(content: Text(data?['message'] ?? 'An error occurred'));
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
        created: widget.payment.created,
        tripUserMap: widget.tripUserMap,
      );
    }));
    if (!mounted) return;
    if (res != null && res) Navigator.pop(context, true);
  }
}
