import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.user});
  final UserModel user;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController upiController = TextEditingController();
  bool nameValid = true;
  bool upiValid = true;
  bool loading = false;
  String countryCode = "", number = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.user.name;
    upiController.text = widget.user.upi_id;
    countryCode = widget.user.country_code;
    number = widget.user.phone;
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
              child: TextField(
                cursorColor: Colors.grey[900],
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
                                width: 0, style: BorderStyle.none)),
                        labelText: 'Name',
                        fillColor: Colors.white,
                        filled: true)
                    : const InputDecoration(
                        errorText: 'Please Enter a valid Name'),
              ),
            ),
            SizedBox(
              height: deviceWidth * 0.05,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                child: IntlPhoneField(
                  initialValue: widget.user.country_code + widget.user.phone,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                      labelText: 'Mobile',
                      fillColor: Colors.white,
                      filled: true),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    setState(() {
                      countryCode = phone.countryCode;
                      number = phone.number;
                    });
                  },
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
              child: TextField(
                cursorColor: Colors.grey[900],
                onChanged: (text) {
                  setState(() {
                    upiValid = true;
                  });
                },
                controller: upiController,
                decoration: upiValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                        labelText: 'UPI ID',
                        fillColor: Colors.white,
                        filled: true)
                    : const InputDecoration(
                        errorText: 'Please Enter a valid Upi id'),
              ),
            ),
            SizedBox(
              height: deviceWidth * 0.05,
            ),
            GestureDetector(
              onTap: () async {
                haptics();
                editProfile();
              },
              child: Container(
                width: deviceWidth * .90,
                height: deviceWidth * .14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          height: deviceWidth * 0.08,
                          width: deviceWidth * 0.08,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: deviceWidth * .040,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isValidUpiId(String upiId) {
    return RegExp(r'^[a-z0-9.-]{2,256}@[a-z]{2,64}$').hasMatch(upiId);
  }

  void editProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool res = isValidUpiId(upiController.text);
    bool res2 = nameController.text.isNotEmpty;
    setState(() {
      upiValid = res;
      nameValid = res2;
      loading = true;
    });
    if (!res || !res2) {
      setState(() {
        loading = false;
      });
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/auth/update-profile",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({
          "name": nameController.text,
          "country_code": countryCode,
          "number": number,
          "upi_id": upiController.text
        }),
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        prefs.setString('user', jsonEncode(UserModel.fromJson(data['user'])));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (builder) => HomePage(
                  curridx: 3,
                )));
        const snackBar = SnackBar(
          content: Text('Profile Updated'),
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
