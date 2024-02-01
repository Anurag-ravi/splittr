import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:splittr/models/trip.dart';

class TripSetting extends StatefulWidget {
  const TripSetting({super.key, required this.trip, required this.free});
  final TripModel trip;
  final bool free;

  @override
  State<TripSetting> createState() => _TripSettingState();
}

class _TripSettingState extends State<TripSetting> {
  String name = "";
  TextEditingController controller = TextEditingController();

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
    return Scaffold(
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
          if (index == 0)
            return Container(
              height: 100,
              width: deviceWidth,
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey, width: 0.5))),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Details',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 75,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/trip.png'))),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
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
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
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
          if (index == 1)
            return const SizedBox(
              height: 10,
            );
          if (index == 2)
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
          if (index == 3)
            return const Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.group_add_outlined, color: Colors.white, size: 25),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Add people to group',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            );
          if (index == 4)
            return GestureDetector(
              onTap: () {
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
          if (index == widget.trip.users.length + 5)
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
          if (index == widget.trip.users.length + 6)
            return Padding(
              padding: EdgeInsets.all(15),
              child: Opacity(
                opacity: widget.free ? 1 : 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.exit_to_app_outlined,
                        color: Colors.white, size: 25),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave Group',
                          style: TextStyle(color: Colors.white),
                        ),
                        widget.free
                            ? Container()
                            : Container(
                                width: deviceWidth - 80,
                                child: Text(
                                  "You can't leave this group because you have outstanding debts with other group members. Please make sure all of your debts have been settled up, and try again.",
                                  softWrap: true,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                      ],
                    )
                  ],
                ),
              ),
            );
          if (index == widget.trip.users.length + 7)
            return const Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 25),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Delete group',
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
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
                SizedBox(
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
}