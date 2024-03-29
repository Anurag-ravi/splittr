import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/editProfile.dart';
import 'package:splittr/pages/login.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() {
    setState(() {
      user = Boxes.getMe().get('me')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 150,
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
                    'Account',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 70,
                          height: 70,
                          child: Image.asset("assets/profile/${user.dp}.png"),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfile(user: user)));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Opacity(
            opacity: 0.2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.qr_code, color: Colors.white, size: 30),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Scan Code',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Preferences',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const Opacity(
            opacity: 0.2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.email_outlined, color: Colors.white, size: 30),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Email settings',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const Opacity(
            opacity: 0.2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_none_outlined,
                      color: Colors.white, size: 30),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Notifications settings',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const Opacity(
            opacity: 0.2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: Colors.white, size: 30),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Passcode',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Feedback',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              haptics();
              double rating = 0;
              String feedback = "";
              final res = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Rate us',
                        style: TextStyle(fontSize: 18),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // choose star rating widget
                          RatingBar.builder(
                            initialRating: 5,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (val) {
                              rating = val;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Give us some feedback',
                            style: TextStyle(fontSize: 14),
                          ),
                          TextField(
                            onChanged: (value) {
                              feedback = value;
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Submit'))
                      ],
                    );
                  });
              if (res == null || !res) {
                return;
              }
              addLog("Rating: ${rating}, ${feedback}", user.name, "feedback");
            },
            child: const Opacity(
              opacity: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.star_outlined, color: Colors.white, size: 30),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Rate us',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              haptics();
              String feedback = "";
              final res = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Bug/Feature Request',
                        style: TextStyle(fontSize: 18),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Please describe the bug or feature request',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            maxLines: 3,
                            onChanged: (value) {
                              feedback = value;
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Submit'))
                      ],
                    );
                  });
              if (res == null || !res) {
                return;
              }
              addLog(feedback, user.name, "bug/feature");
            },
            child: const Opacity(
              opacity: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.bug_report_outlined,
                        color: Colors.white, size: 30),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Bug/Feature Request',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              haptics();
              String feedback = "";
              final res = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Support Request',
                        style: TextStyle(fontSize: 18),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Please describe the problem you are facing',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            maxLines: 3,
                            onChanged: (value) {
                              feedback = value;
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Submit'))
                      ],
                    );
                  });
              if (res == null || !res) {
                return;
              }
              addLog(feedback, user.name, "support");
            },
            child: const Opacity(
              opacity: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.question_mark_outlined,
                        color: Colors.white, size: 30),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Support',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: deviceWidth,
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Colors.grey, width: 0.5))),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      haptics();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('registered_now', true);
                      await prefs.remove('token');
                      await prefs.remove('user');
                      Boxes.getMe().clear();
                      Boxes.getUsers().clear();
                      Boxes.getShortTrips().clear();
                      Boxes.getTrips().clear();
                      FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signOut();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (builder) => LoginPage()));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout_rounded, color: mainGreen, size: 30),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Log out',
                          style: TextStyle(color: mainGreen),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Made with ❤️ by Anurag',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Build number: ${const String.fromEnvironment('TAG')}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
