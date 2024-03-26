import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/addNewContact.dart';
import 'package:splittr/screens/groupScreen.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class AddToGroup extends StatefulWidget {
  const AddToGroup({super.key, required this.trip});
  final TripModel trip;

  @override
  State<AddToGroup> createState() => _AddToGroupState();
}

class _AddToGroupState extends State<AddToGroup> {
  List<String> numbers = [];
  List<UserModel> friends = [];
  List<bool> selected = [];
  bool loading = true, selection = false, api_fetching = false;
  Set<String> involved_users = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() {
    for (var tu in widget.trip.users) {
      setState(() {
        if (tu.involved) {
          involved_users.add(tu.user);
        }
      });
    }
    setState(() {
      loading = true;
      friends = Boxes.getUsers().values.toList();
      selected = List<bool>.filled(friends.length, false);
    });
    setState(() {
      loading = false;
    });
  }

  void getContacts() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? numb = await prefs.getString('numbers');
      if (numb != null) {
        List<String> data = List<String>.from(json.decode(numb));
        setState(() {
          numbers = data;
        });
        await fetchFriends();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Add people to group',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          selection
              ? api_fetching
                  ? Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: mainGreen,
                        strokeWidth: 2,
                      ))
                  : GestureDetector(
                      onTap: () {
                        haptics();
                        add_to_group();
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ))
              : Container()
        ],
      ),
      body: ListView.builder(
        itemCount: friends.length + 3,
        itemBuilder: ((context, idx) {
          if (idx == 0) {
            return GestureDetector(
              onTap: () async {
                haptics();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => AddNewContact(
                              id: widget.trip.id,
                              trip: widget.trip,
                            )));
                if (!mounted) {
                  return;
                }
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(22.5)),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(color: Colors.cyan[200]),
                      child: Center(
                        child: Icon(
                          Icons.group_add,
                          color: Colors.purple[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Add a new contact to Splittr',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  )
                ],
              ),
            );
          }
          if (idx == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, bottom: 15),
              child: Text(
                'Friends on Splittr',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }
          if (idx == friends.length + 2) {
            return Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    haptics();
                    getContacts();
                  },
                  child: ApiLoader(
                    text: loading ? "Refreshing" : "Refresh Friends List",
                    loading: loading,
                  ),
                ),
              ],
            );
          }
          int index = idx - 2;
          bool x = involved_users.contains(friends[index].id);
          return GestureDetector(
            onTap: () {
              if (!x) {
                haptics();
                setState(() {
                  selected[index] = !selected[index];
                  selection = selected.contains(true);
                });
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Opacity(
                  opacity: x ? 0.3 : 1.0,
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
                              "assets/profile/${friends[index].dp}.png"),
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
                            friends[index].name,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          x
                              ? Text(
                                  'Already in group',
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
            ),
          );
        }),
      ),
    );
  }

  Future<void> fetchFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/auth/get-friends",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"contacts": numbers}),
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        var users = data['friends'];
        List<UserModel> temp = [];
        users.forEach((user) => {temp.add(UserModel.fromJson(user))});
        var userBox = Boxes.getUsers();
        var localUsers = userBox.values.toList();
        for (var user in localUsers) {
          if (!temp.contains(user)) {
            userBox.delete(user.id);
          }
        }
        for (var user in temp) {
          await userBox.put(user.id, user);
        }
        setState(() {
          loading = false;
          friends = temp;
          selected = List<bool>.filled(friends.length, false);
        });
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

  Future<void> add_to_group() async {
    setState(() {
      api_fetching = true;
    });
    List<String> selected_users = [];
    for (var i = 0; i < selected.length; i++) {
      if (selected[i]) {
        selected_users.add(friends[i].id);
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/trip/${widget.trip.id}/add-many",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"users": selected_users}),
        prefs,
        context);
    setState(() {
      api_fetching = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        List<TripUser> modified =
            List<TripUser>.from(data['data'].map((x) => TripUser.fromJson(x)));
        widget.trip.users = modified;
        await widget.trip.save();
        setState(() {});
        Navigator.pop(context);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
