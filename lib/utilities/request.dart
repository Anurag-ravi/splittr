import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

dynamic postRequest(String url,Map<String, String> headers, Object body,SharedPreferences prefs) async{
  final res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );
  if(res.statusCode == 200){
    var data = jsonDecode(res.body);
    if(data['token'] != null){
      prefs.setString('token', data['token']);
    }
    return data;
  }
  return null;
}