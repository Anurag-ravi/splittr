import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/createGroup.dart';
import 'package:splittr/pages/joinGroup.dart';
import 'package:splittr/pages/tripPage.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  late SharedPreferences prefs;
  int nets_length = Boxes.getShortTrips().values.length;
  bool loading = false, showSettledUp = false, api_fetching = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Future<void> init() async {
    SharedPreferences t_prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs = t_prefs;
    });
    bool hide = prefs.getBool('hideSettledUp') ?? false;
    setState(() {
      showSettledUp = hide;
    });
    refresh();
  }

  void setPref() {
    prefs.setBool('hideSettledUp', showSettledUp);
  }

  Future<void> refresh() async {
    setState(() {
      api_fetching = true;
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
    if (data != null) {
      if (data['status'] == 200) {
        var tripsList = data['data'];
        List<ShortTripModel> trips = [];
        tripsList.forEach((e) {
          trips.add(ShortTripModel.fromJson(e));
        });
        List<TripModel> tripData = [];
        tripsList.forEach((e) {
          tripData.add(TripModel.fromJson(e));
        });
        // match the data with the local data
        var shortTripBox = Boxes.getShortTrips();
        var tripBox = Boxes.getTrips();
        var localShortTrips = shortTripBox.values.toList();
        var localTrips = tripBox.values.toList();
        for (var x in localShortTrips) {
          bool found = false;
          for (var y in trips) {
            if (x.id == y.id) found = true;
          }
          if (!found) {
            await shortTripBox.delete(x.id);
          }
        }
        for (var x in localTrips) {
          bool found = false;
          for (var y in tripData) {
            if (x.id == y.id) found = true;
          }
          if (!found) {
            await tripBox.delete(x.id);
          }
        }
        for (var x in trips) {
          await shortTripBox.put(x.id, x);
        }
        for (var x in tripData) {
          await tripBox.put(x.id, x);
        }
        setState(() {
          api_fetching = false;
          nets_length = trips.length;
        });
      }
    } else {
      setState(() {
        loading = false;
        api_fetching = false;
      });
      final snackBar = SnackBar(
        content: Text('Error fetching data'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            haptics();
            refresh();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> onRefresh() async {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TripModel>>(
      valueListenable: Boxes.getTrips().listenable(),
      builder: (context, box, _) {
        List<ShortTripModel> trips = Boxes.getShortTrips().values.toList();
        List<TripModel> tripData = Boxes.getTrips().values.toList();
        List<Net> nets = List.generate(
            nets_length, (index) => Net(message: "", color: Colors.white));
        var user = Boxes.getMe().get('me');
        try {
          for (int i = 0; i < tripData.length; i++) {
            var trip = tripData[i];
            String currentTripUser = "";
            Map<String, TripUser> tripUserMap = {};
            for (var tu in trip.users) {
              if (tu.user == user!.id) {
                currentTripUser = tu.id;
              }
              tripUserMap.putIfAbsent(tu.id, () => tu);
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
            if (paid_by_me.toStringAsFixed(2) ==
                paid_for_me.toStringAsFixed(2)) {
              nets[i] = Net(
                  message: "You are all settled up in this group",
                  color: Color(0xfff5f5f5));
            } else if (paid_by_me >= paid_for_me) {
              nets[i] = Net(
                  message:
                      "You are owed ₹${(paid_by_me - paid_for_me).toStringAsFixed(2)} overall",
                  color: mainGreen);
            } else {
              nets[i] = Net(
                  message:
                      "You owe ₹${(paid_for_me - paid_by_me).toStringAsFixed(2)} overall",
                  color: mainOrange);
            }
          }
        } catch (e) {
          print(e);
        }
        return RefreshIndicator(
          onRefresh: () {
            return onRefresh();
          },
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : trips.length == 0
                  ? ListView(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        api_fetching ? ApiLoader() : Container(),
                        Center(
                          child: Text(
                            "You are not involved in any groups",
                            style: TextStyle(color: Colors.grey[100]),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: GestureDetector(
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
                                child: Center(
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
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text("OR",
                                style: TextStyle(color: Colors.grey[100]))),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: GestureDetector(
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
                              child: Center(
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
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount:
                          api_fetching ? trips.length + 2 : trips.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Hide Settled Up Groups',
                                style: TextStyle(color: Colors.grey[100]),
                              ),
                              SizedBox(
                                width: 10,
                              ),
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
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          );
                        }
                        if (api_fetching && idx == 1) {
                          return ApiLoader();
                        }
                        int index = api_fetching ? idx - 2 : idx - 1;
                        return showSettledUp &&
                                nets[index].color == Color(0xfff5f5f5)
                            ? Container()
                            : GestureDetector(
                                onTap: () async {
                                  haptics();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (builder) => TripPage(
                                            id: trips[index].id,
                                            trip: tripData[index],
                                          )));
                                },
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.grey[800]),
                                      height: 90,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width: 100,
                                            height: 80,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/trip.png'))),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                opacity: nets[index].color ==
                                                        Color(0xfff5f5f5)
                                                    ? 0.5
                                                    : 0.9,
                                                child: Text(
                                                  nets[index].message,
                                                  style: TextStyle(
                                                      color: nets[index].color,
                                                      fontWeight:
                                                          FontWeight.w600,
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
      },
    );
  }
}

class ApiLoader extends StatelessWidget {
  const ApiLoader({
    super.key,
    this.text = 'Fetching data',
    this.loading = true,
  });

  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        height: 30,
        width: 150,
        decoration: BoxDecoration(
          // color: mainGreen,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: mainGreen, width: 1),
        ),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !loading
                    ? Container()
                    : Container(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ],
            )),
      ),
    ));
  }
}
