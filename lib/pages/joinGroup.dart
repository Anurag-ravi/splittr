import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  TextEditingController nameController = TextEditingController();
  bool nameValid = true, loading = false;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Join a group',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            loading
                ? const CircularProgressIndicator(
                    color: mainGreen,
                  )
                : GestureDetector(
                    onTap: () {
                      joinTrip();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                          color: mainGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            const SizedBox(
              width: 5,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                child: TextField(
                  cursorColor: mainGreen,
                  style: TextStyle(color: Colors.white),
                  onChanged: (text) {
                    setState(() {
                      nameValid = true;
                    });
                  },
                  controller: nameController,
                  decoration: nameValid
                      ? InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  width: 1, style: BorderStyle.solid)),
                          labelText: 'Group Code',
                          fillColor: Colors.grey[900],
                          filled: true)
                      : const InputDecoration(
                          errorText: 'Please Enter a valid Code'),
                ),
              ),
            ],
          ),
        ));
  }

  void joinTrip() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool res2 = nameController.text.length == 10;
    setState(() {
      nameValid = res2;
      loading = true;
    });
    if (!res2) {
      setState(() {
        loading = false;
      });
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/trip/join",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"code": nameController.text}),
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (builder) => HomePage(
                  curridx: 0,
                )));
        const snackBar = SnackBar(
          content: Text('Joined Group'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          loading = false;
        });
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      loading = false;
    });
  }
}
