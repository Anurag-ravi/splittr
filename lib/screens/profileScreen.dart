import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/login.dart';
import 'package:splittr/utilities/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel user;
  bool loading = true;

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
    double deviceWidth = MediaQuery.of(context).size.width;
    return loading ? Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 150,
            width: deviceWidth,
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account',style: TextStyle(color: Colors.white,fontSize: 20),),
                  SizedBox(height: 17,),
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
                          Text(user.name,style: TextStyle(color: Colors.white,fontSize: 17),),
                          Text(user.email,style: TextStyle(color: Colors.grey,fontSize: 12),),
                        ],
                      ),
                      Container(),
                      IconButton(
                        onPressed: (){}, 
                        icon: Icon(Icons.edit_outlined)
                        )
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 30,),
          Container(
            height: 150,
            width: deviceWidth,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey,width: 0.5))
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('registered_now',true);
                      await prefs.remove('token');
                      await prefs.remove('user');
                      FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => LoginPage()));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout_rounded,color: mainGreen,size: 30),
                        SizedBox(width: 20,),
                        Text('Log out',style: TextStyle(color: mainGreen),)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}