import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/createGroup.dart';
import 'package:splittr/pages/joinGroup.dart';
import 'package:splittr/pages/tripPage.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class Net {
  String message;
  Color color;
  Net({required this.message, required this.color});

  @override
  String toString() {
    return 'Net{message: $message, color: $color}';
  }
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<ShortTripModel> trips = [];
  List<TripModel> tripData = [];
  List<Net> nets = [];
  bool loading = true, showSettledUp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
    init();
  }
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hide = prefs.getBool('hideSettledUp') ?? false;
    setState(() {
      showSettledUp = hide;
    });
  }
  Future<void> setPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hideSettledUp', showSettledUp);
  }

  Future<void> refresh() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await getRequest(
        "${url!}/trip/",
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
        var tripsList = data['data'];
        setState(() {
          List<ShortTripModel> t1 = [];
          tripsList.forEach((e) {
            t1.add(ShortTripModel.fromJson(e));
          });
          List<TripModel> t2 = [];
          tripsList.forEach((e) {
            t2.add(TripModel.fromJson(e));
          });
          trips = t1;
          tripData = t2;
          nets = List.generate(
              trips.length, (index) => Net(message: "", color: Colors.white));
        });
        await findNets();
      }
    }
  }

  Future<void> findNets() async {
    for (var trip in tripData) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentTripUser = "";
      Map<String, TripUser> tripUserMap = {};
      var user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
      for (var tu in trip.users) {
        if (tu.user == user.id) {
          setState(() {
            currentTripUser = tu.id;
          });
        }
        setState(() {
          tripUserMap.putIfAbsent(tu.id, () => tu);
        });
      }
      double paid_by_me = 0.00, paid_for_me = 0.00;
      for (var x in trip.expenses) {
        for (var y in x.paid_by) {
          if (y.user == currentTripUser) paid_by_me += y.amount;
        }
        for (var y in x.paid_for) {
          if (y.user == currentTripUser) paid_for_me += y.amount;
        }
      }
      for (var x in trip.payments) {
        if (x.by == currentTripUser) paid_by_me += x.amount;
        if (x.to == currentTripUser) paid_for_me += x.amount;
      }
      if (paid_by_me.toStringAsFixed(2) == paid_for_me.toStringAsFixed(2)) {
        setState(() {
          nets[tripData.indexOf(trip)] = Net(
              message: "You are all settled up in this group",
              color: Color(0xfff5f5f5));
        });
      } else if (paid_by_me >= paid_for_me) {
        setState(() {
          nets[tripData.indexOf(trip)] = Net(
              message:
                  "You are owed ₹${(paid_by_me - paid_for_me).toStringAsFixed(2)} overall",
              color: mainGreen);
        });
      } else {
        setState(() {
          nets[tripData.indexOf(trip)] = Net(
              message:
                  "You owe ₹${(paid_for_me - paid_by_me).toStringAsFixed(2)} overall",
              color: mainOrange);
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return refresh();
      },
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : trips.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 150,
                      ),
                      Text(
                        "You are not involved in any groups",
                        style: TextStyle(color: Colors.grey[100]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            haptics();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => CreateGroup()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: mainGreen,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                'Create Group',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text("OR", style: TextStyle(color: Colors.grey[100])),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          haptics();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => JoinGroup()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: mainOrange,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              'Join Group',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: trips.length + 1,
                  itemBuilder: (context, idx) {
                    if(idx == 0){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Hide Settled Up Groups', style: TextStyle(color: Colors.grey[100]),),
                          SizedBox(width: 10,),
                          SizedBox(
                            width: 40,
                            height: 30,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                value: showSettledUp,
                                onChanged: (value) {
                                  haptics();
                                  setState(() {
                                    showSettledUp = value;
                                  });
                                  setPref();
                                },
                                activeColor: mainGreen,
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                        ],
                      );
                    }
                    int index = idx - 1;
                    return showSettledUp && nets[index].color == Color(0xfff5f5f5) ? Container() :  GestureDetector(
                      onTap: () async {
                        haptics();
                        final res =
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => TripPage(
                                      id: trips[index].id,
                                    )));
                        if (!mounted) return;
                        if (res != null) {
                          print(res);
                          setState(() {
                            nets[index] = Net(
                                message: res['message'], color: res['color']);
                          });
                        } else {
                          await refresh();
                        }
                      },
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.grey[800]),
                            height: 90,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/trip.png'))),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trips[index].name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                    SizedBox(height: 5),
                                    Opacity(
                                      opacity:
                                          nets[index].color == Color(0xfff5f5f5)
                                              ? 0.5
                                              : 0.9,
                                      child: Text(
                                        nets[index].message,
                                        style: TextStyle(
                                            color: nets[index].color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    );
                  },
                ),
    );
  }
}
