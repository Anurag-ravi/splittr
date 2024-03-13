import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class RemoveFromGroup extends StatefulWidget {
  const RemoveFromGroup({super.key, required this.trip});
  final TripModel trip;

  @override
  State<RemoveFromGroup> createState() => _RemoveFromGroupState();
}

class _RemoveFromGroupState extends State<RemoveFromGroup> {
  List<TripUser> users = [];
  List<bool> selected = [],allowed = [];
  bool loading = false, selection = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      users = widget.trip.users;
      selected = List.filled(users.length, false);
      allowed = List.filled(users.length, true);
    });
    Map<String, double> balances = {};
    for (var user in users) {
      balances[user.id] = 0;
    }
    for (var expense in widget.trip.expenses) {
      for (var by in expense.paid_by) {
        balances[by.user] = balances[by.user]! + by.amount;
      }
      for (var share in expense.paid_for) {
        balances[share.user] = balances[share.user]! - share.amount;
      }
    }
    for (var payment in widget.trip.payments) {
      balances[payment.by] = balances[payment.by]! + payment.amount;
      balances[payment.to] = balances[payment.to]! - payment.amount;
    }
    for (var i = 0; i < users.length; i++) {
      if (roundAmount2(balances[users[i].id]!) != 0.00) {
        setState(() {
          allowed[i] = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Remove people from group',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
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
          selection ? GestureDetector(
            onTap: () {
              haptics();
              remove_from_group();
            },
            child: Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ) : Container()
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: users.length + 1,
              itemBuilder: ((context, idx) {
                if (idx == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, bottom: 15),
                    child: Text(
                      'Friends in this group',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  );
                }
                int index = idx - 1;
                return GestureDetector(
                  onTap: () {
                    haptics();
                    if (!allowed[index]) {
                      return;
                    }
                    setState(() {
                      selected[index] = !selected[index];
                      selection = selected.contains(true);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Opacity(
                      opacity: !allowed[index] ? 0.3 : 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Image.asset(
                                  "assets/profile/${users[index].dp}.png"),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                users[index].name,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              !allowed[index]
                                  ? Text(
                                      'Remaining Unsettled balances',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    )
                                  : Container(),
                            ],
                          ),
                          Expanded(child: Container()),
                          selected[index]
                              ? Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ),
    );
  }

  Future<void> remove_from_group() async {
    setState(() {
      loading = true;
    });
    List<String> selected_users = [];
    for (var i = 0; i < selected.length; i++) {
      if (selected[i]) {
        selected_users.add(users[i].user);
        print('selected: ${users[i].name}');
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/trip/${widget.trip.id}/leave-many",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"users": selected_users}),
        prefs,
        context);
    setState(() {
      loading = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context, true);
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
}