import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/utilities/request.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.id});
  final String id;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool loading = true;
  TripModel? trip;

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
        "${url!}/trip/${widget.id}",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        var trip = TripModel.fromJson(data['data']);
        print(trip);
        setState(() {
          loading = false;
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
          : Column(),
    );
  }
}
