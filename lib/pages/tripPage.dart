import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/pages/addExpense.dart';
import 'package:splittr/utilities/constants.dart';
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
  List<Transaction> transactions = [];

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
        var temp = TripModel.fromJson(data['data']);
        List<Transaction> t_temp = [];
        for (var x in temp.expenses) {
          t_temp.add(Transaction(true, x.created, x, null));
        }
        for (var x in temp.payments) {
          t_temp.add(Transaction(false, x.created, null, x));
        }
        t_temp.sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          loading = false;
          trip = temp;
          transactions = t_temp;
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              backgroundColor: Colors.grey[900],
              appBar: AppBar(
                flexibleSpace: const Opacity(
                  opacity: 0.7,
                  child: Image(
                    image: AssetImage('assets/images/trip3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              floatingActionButton: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => AddExpense(trip: trip!)));
                },
                child: Container(
                  width: 160,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: mainGreen,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Add expense',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return Padding(
                          padding: const EdgeInsets.only(left: 30, top: 20),
                          child: Text(
                            trip!.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        );
                      if (index == 1)
                        return Padding(
                          padding: const EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            "You are owed ₹${2786.32} overall",
                            style: TextStyle(
                              color: mainGreen,
                              fontSize: 17,
                            ),
                          ),
                        );
                      if (index == 2)
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8, top: 20, bottom: 30),
                          child: Container(
                            height: 35,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                HButton(
                                  text: 'Settle up',
                                  color: mainOrange,
                                ),
                                HButton(
                                  text: 'Balances',
                                  color: Colors.grey[900] as Color,
                                ),
                                HButton(
                                  text: 'Totals',
                                  color: Colors.grey[900] as Color,
                                ),
                                HButton(
                                  text: 'Export',
                                  color: Colors.grey[900] as Color,
                                ),
                              ],
                            ),
                          ),
                        );
                    }),
              ),
            ),
    );
  }
}

class HButton extends StatelessWidget {
  const HButton({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            border: Border.all(
              color: Color(0xffa0a0a0),
              width: 0.5,
            )),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
