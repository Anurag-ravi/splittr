import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class AddNewContact extends StatefulWidget {
  const AddNewContact({super.key, required this.id, required this.trip});
  final String id;
  final TripModel trip;

  @override
  State<AddNewContact> createState() => _AddNewContactState();
}

class _AddNewContactState extends State<AddNewContact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool nameValid = true, emailValid = true, loading = false;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Add a new contact',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
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
                      haptics();
                      addToTrip();
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
                          labelText: 'Name',
                          fillColor: Colors.grey[900],
                          filled: true)
                      : const InputDecoration(
                          errorText: 'Name cannot be empty',
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                child: TextField(
                  cursorColor: mainGreen,
                  style: TextStyle(color: Colors.white),
                  onChanged: (text) {
                    setState(() {
                      emailValid = true;
                    });
                  },
                  controller: emailController,
                  decoration: emailValid
                      ? InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  width: 1, style: BorderStyle.solid)),
                          labelText: 'Email',
                          fillColor: Colors.grey[900],
                          filled: true)
                      : const InputDecoration(
                          errorText: 'Invalid Email',
                        ),
                ),
              ),
            ],
          ),
        ));
  }

  bool isValidEmail(email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  void addToTrip() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool res = isValidEmail(emailController.text);
    bool res2 = nameController.text.isNotEmpty;
    setState(() {
      nameValid = res2;
      emailValid = res;
      loading = true;
    });
    if (!res2 || !res) {
      setState(() {
        loading = false;
      });
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/trip/${widget.id}/add-new",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode(
            {"name": nameController.text, "email": emailController.text}),
        prefs,
        context);
    setState(() {
      loading = false;
    });
    if (data != null) {
      if (data['status'] == 200) {
        var snackBar = SnackBar(
          content: Text(data['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        List<TripUser> modified =
            List<TripUser>.from(data['data'].map((x) => TripUser.fromJson(x)));
        widget.trip.users = modified;
        await widget.trip.save();
        setState(() {});
        Navigator.pop(context);
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
