import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/pages/completeSignup.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/utilities/jwt.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  bool inputTextNotNull = false;
  bool emailValid = true;
  String _email = '';
  bool loading = false;
  bool responseLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
      if (event != null) {
        String token = generateToken(event.email!);

        loginToServer(token, event.email!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return responseLoading
        ? const Scaffold(
            backgroundColor: Color(0xFFDCDADD),
            body: Center(child: CircularProgressIndicator()))
        : Scaffold(
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
                    "Welcome Back, you've been missed",
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
                        setState(() {
                          emailValid = true;
                          _email = text.trim();
                          if (emailController.text.length >= 5) {
                            inputTextNotNull = true;
                          } else {
                            inputTextNotNull = false;
                          }
                        });
                      },
                      controller: emailController,
                      decoration: emailValid
                          ? InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                      width: 0, style: BorderStyle.none)),
                              labelText: 'Email',
                              fillColor: Colors.white,
                              filled: true)
                          : const InputDecoration(
                              errorText: 'Please Enter a valid Email'),
                    ),
                  ),
                  SizedBox(height: deviceWidth * 0.02),
                  inputTextNotNull
                      ? GestureDetector(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            bool res = isValidEmail(_email);
                            setState(() {
                              emailValid = res;
                              loading = true;
                            });
                            if (!res) {
                              setState(() {
                                emailValid = false;
                                loading = false;
                              });
                              return;
                            }
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
                                      'Send OTP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: deviceWidth * .040,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        )
                      : Container(
                          width: deviceWidth * .90,
                          height: deviceWidth * .14,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                            child: Text(
                              'Send OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: deviceWidth * .040,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: deviceWidth * .05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1,
                        width: deviceWidth * .25,
                        color: const Color(0xffA2A2A2),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Or continue with',
                        style: TextStyle(
                          fontSize: deviceWidth * .040,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 1,
                        width: deviceWidth * .25,
                        color: const Color(0xffA2A2A2),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: deviceWidth * .1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          googleSignin();
                        },
                        child: Container(
                            width: deviceWidth * 0.25,
                            height: deviceWidth * 0.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(deviceWidth * 0.05)),
                            ),
                            child: Center(
                                child: SvgPicture.asset(
                              'assets/icons/google.svg',
                              height: deviceWidth * 0.17,
                            ))),
                      ),
                      GestureDetector(
                        onTap: () {
                          auth.signOut();
                        },
                        child: Container(
                            width: deviceWidth * 0.25,
                            height: deviceWidth * 0.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(deviceWidth * 0.05)),
                            ),
                            child: Center(
                                child: SvgPicture.asset(
                              'assets/icons/facebook.svg',
                              height: deviceWidth * 0.17,
                            ))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: deviceWidth * .1,
                  ),
                  _user != null ? Text(_user!.email!) : Container(),
                  Container(
                    width: deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: deviceWidth * .035,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: deviceWidth * .035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  bool isValidEmail(email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  void googleSignin() {
    try {
      GoogleAuthProvider provider = GoogleAuthProvider();
      auth.signInWithProvider(provider);
    } catch (err) {
      print(err);
    }
  }

  void loginToServer(String token, String email) async {
    setState(() {
      responseLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    prefs.setString('email', email);
    final response = await http.post(Uri.parse("${url!}/auth/oauth-login"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"token": token}));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 200) {
        String token = data['token'];
        bool registeredNow = data['registered_now'];
        prefs.setBool('registered_now', registeredNow);
        prefs.setString("token", token);
        if (registeredNow) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (builder) => CompleteSignUp(
                    email: email,
                  )));
        } else {
          prefs.setString('user', jsonEncode(UserModel.fromJson(data['user'])));
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (builder) => HomePage(
                    curridx: 0,
                  )));
        }
        const snackBar = SnackBar(
          content: Text('Succcessfully Logged in'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          responseLoading = false;
        });
        return;
      }
    }
    var snackBar = SnackBar(
      content: Text(data['message']),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      responseLoading = false;
    });
  }
}
