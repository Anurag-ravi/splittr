import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/comment.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/addExpense.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/request.dart';
import 'package:splittr/widgets/comment_tile.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage(
      {super.key,
      required this.expense,
      required this.trip,
      required this.tripUserMap});
  final ExpenseModel expense;
  final Map<String, TripUser> tripUserMap;
  final TripModel trip;

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final List months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  List<String> nets = [];
  List<CommentModel> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool loading = false;
  bool sendingComment = false;
  String? myUserId;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void init() {
    final me = Boxes.getMe().get('me');
    myUserId = me?.id;

    Map<TripUser, double> paid = {}, owed = {};
    for (var x in widget.expense.paid_by) {
      paid[widget.tripUserMap[x.user]!] = x.amount;
    }
    for (var x in widget.expense.paid_for) {
      owed[widget.tripUserMap[x.user]!] = x.amount;
    }
    List<String> t1 = [], t2 = [];
    widget.tripUserMap.forEach((id, tripuser) {
      String a = tripuser.name.trim();
      bool involved = false;
      bool comesFirst = false;
      if (paid.containsKey(tripuser)) {
        involved = true;
        comesFirst = true;
        a += " paid ₹${paid[tripuser]!.toStringAsFixed(2)}";
      }
      if (owed.containsKey(tripuser)) {
        if (involved) a += " and";
        involved = true;
        a += " owed ₹${owed[tripuser]!.toStringAsFixed(2)}";
      }
      if (involved) {
        if (comesFirst) {
          t1.add(a);
        } else {
          t2.add(a);
        }
      }
    });
    setState(() {
      nets.addAll(t1);
      nets.addAll(t2);
      comments = List<CommentModel>.from(widget.expense.comments ?? []);
    });
    refreshComments();
  }

  Future<void> refreshComments() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    final data = await getRequest(
        "$url/comment/expense/${widget.expense.id}",
        {'Accept': 'application/json', 'Authorization': token!},
        prefs,
        context);
    if (data != null && data['status'] == 200) {
      final fetched = (data['data'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();
      widget.expense.comments = fetched;
      final box = Boxes.getExpenses();
      await box.put(widget.expense.id, widget.expense);
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
        {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': token!},
        jsonEncode({
          'entity_type': 'expense',
          'entity_id': widget.expense.id,
          'trip': widget.expense.trip,
          'title': 'Comment added on expense "${widget.expense.name}"',
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
        {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': token!},
        context);
    if (data != null && data['status'] == 200) {
      widget.expense.comments?.removeWhere((c) => c.id == commentId);
      final box = Boxes.getExpenses();
      await box.put(widget.expense.id, widget.expense);
      if (mounted) {
        setState(() {
          comments.removeWhere((c) => c.id == commentId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // total items = 3 header rows + nets + 1 divider + comments
    final int totalItems = 3 + nets.length + 1 + comments.length;
    return RefreshIndicator(
      onRefresh: refreshComments,
      child: Stack(
        children: [
          Opacity(
            opacity: loading ? 0.5 : 1,
            child: Scaffold(
              backgroundColor: Colors.grey[900],
              appBar: AppBar(
                backgroundColor: Colors.pink[50],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, {'changed': false, 'expense': widget.expense});
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: handleDelete,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: handleEdit,
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: totalItems,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: Image.asset(
                                    'assets/categories/${widget.expense.category}.png',
                                    height: 45.0,
                                    width: 45.0,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.expense.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.ellipsis),
                                    ),
                                    Text(
                                      "₹ ${widget.expense.amount.toStringAsFixed(2)}",
                                      style: const TextStyle(color: Colors.white, fontSize: 15, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        if (index == 1) {
                          int hour = widget.expense.created.hour;
                          String ampm = "AM";
                          if (hour > 12) { hour -= 12; ampm = "PM"; }
                          if (hour == 0) hour = 12;
                          String hr = hour < 10 ? "0$hour" : "$hour";
                          String min = widget.expense.created.minute < 10
                              ? "0${widget.expense.created.minute}"
                              : "${widget.expense.created.minute}";
                          return Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              "Added on ${months[widget.expense.created.month - 1]} ${widget.expense.created.day}, ${widget.expense.created.year} at $hr:$min $ampm",
                              style: const TextStyle(color: Colors.white, fontSize: 12, overflow: TextOverflow.ellipsis),
                            ),
                          );
                        }
                        if (index == 2) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, left: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.asset(
                                    'assets/profile/${widget.tripUserMap[widget.expense.paid_by[0].user]!.dp}.png',
                                    height: 50.0,
                                    width: 50.0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.expense.paid_by.length == 1
                                      ? "${widget.tripUserMap[widget.expense.paid_by[0].user]!.name} paid ₹${widget.expense.amount}"
                                      : "${widget.expense.paid_by.length} people paid ₹${widget.expense.amount.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 14, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }
                        if (index < 3 + nets.length) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 75, top: 10),
                            child: Text(
                              nets[index - 3],
                              style: const TextStyle(color: Colors.white, fontSize: 12, overflow: TextOverflow.ellipsis),
                            ),
                          );
                        }
                        // Activity divider
                        if (index == 3 + nets.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 8, left: 15, right: 15),
                            child: Row(
                              children: [
                                const Text("Activity", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Expanded(child: Divider(color: Colors.white24)),
                              ],
                            ),
                          );
                        }
                        // Comment rows
                        final comment = comments[index - 3 - nets.length - 1];
                        return CommentTile(
                          comment: comment,
                          tripUserMap: widget.tripUserMap,
                          myUserId: myUserId,
                          onDelete: () => deleteComment(comment.id),
                        );
                      },
                    ),
                  ),
                  _buildCommentInput(),
                ],
              ),
            ),
          ),
          if (loading) const Center(child: CircularProgressIndicator()),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => postComment(),
            ),
          ),
          const SizedBox(width: 8),
          sendingComment
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: postComment,
                ),
        ],
      ),
    );
  }

  Future<void> handleDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will permanently delete this data'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (result == null || !result) return;
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    setState(() => loading = true);
    final data = await deleteRequest(
        "${url!}/expense/${widget.expense.id}",
        {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': token!},
        context);
    if (data != null && data['status'] == 200) {
      setState(() => loading = false);
      const snackBar = SnackBar(content: Text('Expense deleted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context, {'changed': true, 'expense': null});
      return;
    }
    setState(() => loading = false);
  }

  void handleEdit() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddExpense(trip: widget.trip, updating: true, expense: widget.expense);
    }));
    if (res != null && res['changed'] == true) Navigator.pop(context, res);
  }
}
