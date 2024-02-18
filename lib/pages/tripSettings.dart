import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/pages/addToGroup.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class TripSetting extends StatefulWidget {
  const TripSetting({super.key, required this.trip, required this.free,required this.currentTripUser,required this.deletable});
  final TripModel trip;
  final bool free;
  final bool deletable;
  final String currentTripUser;

  @override
  State<TripSetting> createState() => _TripSettingState();
}

class _TripSettingState extends State<TripSetting> {
  String name = "";
  TextEditingController controller = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      name = widget.trip.name;
      controller.text = widget.trip.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                'Group Settings',
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
            ),
            body: ListView.builder(
              itemCount: widget.trip.users.length + 8,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    height: 100,
                    width: deviceWidth,
                    decoration: const BoxDecoration(
                        border: Border.symmetric(
                            horizontal:
                                BorderSide(color: Colors.grey, width: 0.5))),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Group Details',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 75,
                                height: 60,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/images/trip.png'))),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit trip name'),
                                      content: TextField(
                                        controller: controller,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              name = controller.text;
                                            });
                                            Navigator.pop(context, 'Ok');
                                            handleEditName();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (index == 1) {
                  return const SizedBox(
                    height: 10,
                  );
                }
                if (index == 2) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Group Members',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                if (index == 3) {
                  return GestureDetector(
                    onTap: () async {
                      haptics();
                      final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) =>
                                  AddToGroup(trip: widget.trip)));
                      if (!mounted) return;
                      if (res) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.group_add_outlined,
                              color: Colors.white, size: 25),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Add people to group',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (index == 4) {
                  return GestureDetector(
                    onTap: () {
                      haptics();
                      FlutterShare.share(
                          title: 'Invite to Group',
                          text:
                              "Use this code: ${widget.trip.code} to join my Splittr Group: ${widget.trip.name}");
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.link, color: Colors.white, size: 25),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Invite via link',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (index == widget.trip.users.length + 5) {
                  return const Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Text(
                          'Advanced settings',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                if (index == widget.trip.users.length + 6) {
                  return GestureDetector(
                    onTap: () {
                      haptics();
                      handleLeave();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Opacity(
                        opacity: widget.free ? 1 : 0.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.exit_to_app_outlined,
                                color: Colors.white, size: 25),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Leave Group',
                                  style: TextStyle(color: Colors.white),
                                ),
                                widget.free
                                    ? Container()
                                    : Container(
                                        width: deviceWidth - 80,
                                        child: const Text(
                                          "You can't leave this group because you have outstanding debts with other group members. Please make sure all of your debts have been settled up, and try again.",
                                          softWrap: true,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (index == widget.trip.users.length + 7) {
                  return GestureDetector(
                    onTap: () {
                      haptics();
                      handleDelete();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Opacity(
                          opacity: widget.trip.created_by == widget.currentTripUser && widget.deletable ? 1 : 0.2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 25),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delete Group',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  widget.trip.created_by == widget.currentTripUser && widget.deletable
                                      ? Container()
                                      : Container(
                                          width: deviceWidth - 80,
                                          child: Text(
                                            widget.trip.created_by == widget.currentTripUser ? "You can't delete this group because there are outstanding debts with other group members. Please make sure all of the debts have been settled up, and try again." : "You can't delete this group because you are not the creator of this group.",
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        ),
                    ),
                  );
                }

                if (!widget.trip.users[index - 5].involved) return Container();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                              "assets/profile/${widget.trip.users[index - 5].dp}.png"),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.trip.users[index - 5].name,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Future<void> handleLeave() async {
    if (!widget.free) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will remove you from this group'),
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
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await getRequest(
        "${url!}/trip/${widget.trip.id}/leave",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (builder) => HomePage(curridx: 0)));
        return;
      } else {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
  }

  Future<void> handleDelete() async {
    if (widget.trip.created_by != widget.currentTripUser || !widget.deletable) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will permanently delete this group and all of its data. This action cannot be undone.'),
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
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await deleteRequest(
        "${url!}/trip/${widget.trip.id}",
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
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (builder) => HomePage(curridx: 0)));
        return;
      } else {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
  }

  Future<void> handleEditName() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/trip/${widget.trip.id}/edit",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"name": name}),
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
      } else {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
  }
}
