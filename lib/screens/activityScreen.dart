import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Will be implemented soon',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
