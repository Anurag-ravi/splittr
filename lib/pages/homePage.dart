import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/screens/activityScreen.dart';
import 'package:splittr/screens/friendsScreen.dart';
import 'package:splittr/screens/groupScreen.dart';
import 'package:splittr/screens/profileScreen.dart';
import 'package:splittr/utilities/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currIndex = 0;
  late UserModel user;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
      loading = false;
    });
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
          currIndex == 0 ? IconButton(
            icon: Icon(Icons.group_add_outlined),
            color: Colors.white,
            onPressed: () {},
          ) : Container(),
        ],
      ),
      body: currIndex == 0 ? GroupScreen() :
            currIndex == 1 ? FriendScreen():
            currIndex == 2? ActivityScreen():
            ProfileScreen(),
      bottomNavigationBar: Container(
        height: 55,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey,width: 1))
        ),
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
                onTap: (){
                  setState(() {
                    currIndex = 0;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.group_outlined,color: currIndex == 0 ? mainGreen : Colors.white,),
                    Text('Group',style: TextStyle(color: currIndex == 0 ? mainGreen : Colors.white),)
                  ],
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: GestureDetector(
                onTap: (){
                  setState(() {
                    currIndex = 1;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.person_outline,color: currIndex == 1 ? mainGreen : Colors.white,),
                    Text('Friends',style: TextStyle(color: currIndex == 1 ? mainGreen : Colors.white),)
                  ],
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: GestureDetector(
                onTap: (){
                  setState(() {
                    currIndex = 2;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.show_chart_outlined,color: currIndex == 2 ? mainGreen : Colors.white,),
                    Text('Activity',style: TextStyle(color: currIndex == 2 ? mainGreen : Colors.white),)
                  ],
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: GestureDetector(
                onTap: (){
                  setState(() {
                    currIndex = 3;
                  });
                },
                child: Column(
                  children: [
                    loading ? Icon(Icons.person_outline,color: currIndex == 2 ? mainGreen : Colors.white,)
                    : ClipOval(
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[900],
                        radius: 13,
                        backgroundImage: AssetImage("assets/profile/${user.dp}.png"),
                      ),
                    ),
                    Text('Account',style: TextStyle(color: currIndex == 3 ? mainGreen : Colors.white),)
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}