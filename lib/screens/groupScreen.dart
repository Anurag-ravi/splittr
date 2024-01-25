import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/pages/tripPage.dart';
import 'package:splittr/utilities/request.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<ShortTripModel> trips = [];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
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
    if (data != null) {
      if (data['status'] == 200) {
        var trips = data['data'];
        List<ShortTripModel> temp = [];
        trips.forEach((trip) => {temp.add(ShortTripModel.fromJson(trip))});
        setState(() {
          loading = false;
          this.trips = temp;
        });
        return;
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
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => TripPage(
                              id: trips[index].id,
                            )));
                  },
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                              children: [
                                Text(
                                  trips[index].name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '',
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
