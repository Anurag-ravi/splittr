import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompleteSignUp extends StatefulWidget {
  const CompleteSignUp({super.key,required this.email});

  final String email;

  @override
  State<CompleteSignUp> createState() => _CompleteSignUpState();
}

class _CompleteSignUpState extends State<CompleteSignUp> {

  TextEditingController emailController = TextEditingController();
  bool inputTextNotNull = false;
  bool emailValid = true;
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
              "Complete the Signup",
              style: TextStyle(
                fontSize: deviceWidth * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceWidth * 0.1),
            Text(
              widget.email,
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
          ]
        )
      )
    );
  }
}