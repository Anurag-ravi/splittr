import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/utilities/request.dart';

class CompleteSignUp extends StatefulWidget {
  const CompleteSignUp({super.key,required this.email});

  final String email;

  @override
  State<CompleteSignUp> createState() => _CompleteSignUpState();
}

class _CompleteSignUpState extends State<CompleteSignUp> {

  TextEditingController nameController = TextEditingController();
  TextEditingController upiController = TextEditingController();
  bool nameValid = true;
  bool upiValid = true;
  bool loading = false;
  String countryCode = "",number = "";

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFDCDADD),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: deviceWidth * 0.2),
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: deviceWidth * 0.35,
            ),
            SizedBox(height: deviceWidth * 0.1),
            Text(
              "Complete the Signup",
              style: TextStyle(
                fontSize: deviceWidth * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceWidth * 0.03),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: deviceWidth * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceWidth * 0.05,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:  deviceWidth * 0.05),
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
            SizedBox(height: deviceWidth * 0.05,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:  deviceWidth * 0.05),
              child: IntlPhoneField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          width: 0, style: BorderStyle.none)),
                  labelText: 'Mobile',
                  fillColor: Colors.white,
                  filled: true
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  setState(() {
                    countryCode = phone.countryCode;
                    number = phone.number;
                  });
                },

              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:  deviceWidth * 0.05),
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
            SizedBox(height: deviceWidth * 0.05,),
            GestureDetector(
              onTap: () async {
                register();
              },
              child: Container(
                width: deviceWidth * .90,
                height: deviceWidth * .14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(5)),
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
          ]
        )
      )
    );
  }
  bool isValidUpiId(String upiId) {
    return RegExp(r'^[a-z0-9.-]{2,256}@[a-z]{2,64}$').hasMatch(upiId);
  }
  void register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool res = isValidUpiId(upiController.text);
    bool res2 = nameController.text.length > 0;
    setState(() {
      upiValid = res;
      nameValid = res2;
      loading = true;
    });
    if(!res || !res2) {
      setState(() {
        loading = false;
      });
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
      "${url!}/auth/oauth-register",
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
      prefs);
    if(data!=null){
      if(data['status'] == 200){
        prefs.setBool('registered_now', false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => HomePage()));
        const snackBar = SnackBar(
        content: Text('Succcessfully Registered'),
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