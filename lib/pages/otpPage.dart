import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/completeSignup.dart';
import 'package:splittr/pages/homePage.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key, required this.hash, required this.email});
  final String hash;
  final String email;

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  String otp = "";
  TextEditingController otpController = TextEditingController();
  bool loading = false;
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
              "OTP sent to ${widget.email}",
              style: TextStyle(
                fontSize: deviceWidth * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(deviceWidth * 0.05),
              child: TextField(
                  cursorColor: Colors.grey[900],
                  onChanged: (text) {
                    setState(() {});
                  },
                  controller: otpController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                      labelText: 'OTP',
                      fillColor: Colors.white,
                      filled: true)),
            ),
            SizedBox(height: deviceWidth * 0.02),
            GestureDetector(
              onTap: () async {
                verifyOTP();
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
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: deviceWidth * .040,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: deviceWidth * .05,
            ),
          ],
        ),
      ),
    );
  }

  void verifyOTP() async {
    try {
      setState(() {
        loading = true;
      });
      FocusManager.instance.primaryFocus?.unfocus();
      if (otpController.text.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP"),
          ),
        );
        setState(() {
          loading = false;
        });
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString('url');
      prefs.setString('email', widget.email);
      final response = await http.post(Uri.parse("${url!}/auth/otp-verify"),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "email": widget.email,
            "otp": otpController.text,
            "hash": widget.hash
          }));
      setState(() {
        loading = false;
      });
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == 200) {
          String token = data['token'];
          bool registeredNow = data['registered_now'];
          prefs.setBool('registered_now', registeredNow);
          prefs.setString("token", token);
          const snackBar = SnackBar(
            content: Text('Succcessfully Logged in'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          if (registeredNow) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (builder) => CompleteSignUp(
                      email: widget.email,
                    )));
          } else {
            prefs.setString(
                'user', jsonEncode(UserModel.fromJson(data['user'])));
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (builder) => HomePage(
                      curridx: 0,
                    )));
          }
          return;
        }
      }
      var snackBar = SnackBar(
        content: Text(data['message']),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
      var snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
