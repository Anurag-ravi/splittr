import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/pages/login.dart';

dynamic postRequest(String url, Map<String, String> headers, Object body,
    SharedPreferences prefs, BuildContext context) async {
  final res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body);
    if (data['status'] == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registered_now', true);
      await prefs.remove('token');
      await prefs.remove('user');
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => LoginPage()));
      return null;
    }
    if (data['token'] != null) {
      prefs.setString('token', data['token']);
    }
    return data;
  }
  return null;
}

dynamic getRequest(String url, Map<String, String> headers,
    SharedPreferences prefs, BuildContext context) async {
  final res = await http.get(
    Uri.parse(url),
    headers: headers,
  );
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body);
    if (data['status'] == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registered_now', true);
      await prefs.remove('token');
      await prefs.remove('user');
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => LoginPage()));
      return null;
    }
    if (data['token'] != null) {
      prefs.setString('token', data['token']);
    }
    return data;
  }
  return null;
}
