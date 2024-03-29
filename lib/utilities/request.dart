import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/pages/login.dart';

dynamic postRequest(String url, Map<String, String> headers, Object body,
    SharedPreferences prefs, BuildContext context) async {
  try {
    final res = await http
        .post(
      Uri.parse(url),
      headers: headers,
      body: body,
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      return http.Response('{"status": 500}', 500);
    });
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
  } catch (e) {
    return null;
  }
}

dynamic getRequest(String url, Map<String, String> headers,
    SharedPreferences prefs, BuildContext context) async {
  try {
    final res = await http
        .get(
      Uri.parse(url),
      headers: headers,
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      return http.Response('{"status": 500}', 500);
    });
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
  } catch (e) {
    return null;
  }
}

dynamic deleteRequest(
    String url, Map<String, String> headers, BuildContext context) async {
  try {
    final res = await http
        .delete(
      Uri.parse(url),
      headers: headers,
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      return http.Response('{"status": 500}', 500);
    });
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      return data;
    }
    return null;
  } catch (e) {
    return null;
  }
}

void addLog(String message, String user, String category) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url = prefs.getString('url')! + '/log';

  await http
      .post(Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(
              {"message": message, "user": user, "category": category}))
      .timeout(Duration(seconds: 10), onTimeout: () {
    return http.Response('{"status": 500}', 500);
  });
  return;
}
