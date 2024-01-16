import 'package:flutter/material.dart';

class CompleteSignUp extends StatefulWidget {
  const CompleteSignUp({super.key});

  @override
  State<CompleteSignUp> createState() => _CompleteSignUpState();
}

class _CompleteSignUpState extends State<CompleteSignUp> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Complete Sign Up'),
      ),
    );
  }
}