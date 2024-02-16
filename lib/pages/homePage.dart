import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/createGroup.dart';
import 'package:splittr/pages/joinGroup.dart';
import 'package:splittr/screens/activityScreen.dart';
import 'package:splittr/screens/friendsScreen.dart';
import 'package:splittr/screens/groupScreen.dart';
import 'package:splittr/screens/profileScreen.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.curridx});
  final int curridx;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currIndex = 0;
  late UserModel user;
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currIndex = widget.curridx;
    init();
  }

  void init() async {
    checkForNewRelease();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
      loading = false;
    });
  }

  Future<void> checkForNewRelease() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool readyForUpdate = prefs.getBool('update') ?? true;
    if(!readyForUpdate) return;
    String currentTag = const String.fromEnvironment('TAG');
    String token = const String.fromEnvironment('GITHUB_TOKEN');
    var response = await http.get(
        Uri.parse('https://api.github.com/repos/Anurag-ravi/splittr/releases'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer ${token}',
          'X-GitHub-Api-Version': '2022-11-28',
        });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if(data.length == 0) return;
      if (data[0]['tag_name'] != currentTag) {
        String download_url = data[0]['assets'][0]['browser_download_url'];
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('New Update Available'),
                content: Text('A new update is available. Please update the app'),
                actions: [
                  TextButton(
                      onPressed: () {
                        prefs.setBool('update', false);
                        Navigator.of(context).pop();
                      },
                      child: Text('Later')),
                  TextButton(
                      onPressed: () {
                        prefs.setBool('update', false);
                        Navigator.of(context).pop();
                        // Open download_url in browser
                        launchUrl(
                            Uri.parse(download_url),
                          );
                      },
                      child: Text('Update'))
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {},
            ),
            currIndex == 0
                ? IconButton(
                    icon: Icon(Icons.add_box_outlined),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => CreateGroup()));
                    },
                  )
                : Container(),
            currIndex == 0
                ? IconButton(
                    icon: Icon(Icons.group_add_outlined),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (builder) => JoinGroup()));
                    },
                  )
                : Container(),
          ],
        ),
        body: currIndex == 0
            ? GroupScreen()
            : currIndex == 1
                ? FriendScreen()
                : currIndex == 2
                    ? ActivityScreen()
                    : ProfileScreen(),
        bottomNavigationBar: Container(
          height: 55,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 1))),
          child: BottomNavigationBar(
            backgroundColor: Colors.grey[900],
            selectedFontSize: 0,
            unselectedFontSize: 0,
            currentIndex: currIndex,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(
              color: mainGreen,
            ),
            selectedItemColor: mainGreen,
            items: [
              BottomNavigationBarItem(
                label: '',
                icon: GestureDetector(
                  onTap: () {
                    haptics();
                    setState(() {
                      currIndex = 0;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        color: currIndex == 0 ? mainGreen : Colors.white,
                      ),
                      Text(
                        'Group',
                        style: TextStyle(
                            color: currIndex == 0 ? mainGreen : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: GestureDetector(
                  onTap: () {
                    haptics();
                    setState(() {
                      currIndex = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: currIndex == 1 ? mainGreen : Colors.white,
                      ),
                      Text(
                        'Friends',
                        style: TextStyle(
                            color: currIndex == 1 ? mainGreen : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: GestureDetector(
                  onTap: () {
                    haptics();
                    setState(() {
                      currIndex = 2;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        color: currIndex == 2 ? mainGreen : Colors.white,
                      ),
                      Text(
                        'Activity',
                        style: TextStyle(
                            color: currIndex == 2 ? mainGreen : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: GestureDetector(
                  onTap: () {
                    haptics();
                    setState(() {
                      currIndex = 3;
                    });
                  },
                  child: Column(
                    children: [
                      loading
                          ? Icon(
                              Icons.person_outline,
                              color: currIndex == 2 ? mainGreen : Colors.white,
                            )
                          : ClipOval(
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[900],
                                radius: 13,
                                backgroundImage:
                                    AssetImage("assets/profile/${user.dp}.png"),
                              ),
                            ),
                      Text(
                        'Account',
                        style: TextStyle(
                            color: currIndex == 3 ? mainGreen : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
