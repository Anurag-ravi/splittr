import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/user.dart';
import 'package:splittr/screens/groupScreen.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/request.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<Contact> contacts = [];
  List<String> numbers = [];
  List<UserModel> friends = [];
  bool loading = true, api_fetching = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts();
  }

  void getContacts() async {
    setState(() {
      loading = true;
      api_fetching = true;
      friends = Boxes.getUsers().values.toList();
    });
    setState(() {
      loading = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? numb = await prefs.getString('numbers');
      if (numb != null) {
        List<String> data = List<String>.from(json.decode(numb));
        setState(() {
          numbers = data;
        });
        await fetchFriends();
      }
    } catch (e) {
      print(e);
    }

    if (!await Permission.contacts.isGranted) {
      await Permission.contacts.request();
      if (await Permission.contacts.isPermanentlyDenied) {
        var snackBar = SnackBar(
          content:
              Text("Grant contacts permission from settings to view friends"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        openAppSettings();
      }
      if (!await Permission.contacts.isGranted) {
        var snackBar = SnackBar(
          content: Text("Without contacts, you can't view friends"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    var ccc = await ContactsService.getContacts();
    List<String> cc = [];
    for (var contact in ccc) {
      if (contact.phones != null) {
        for (var phone in contact.phones!) {
          String num = "";
          for (var i = 0; i < phone.value!.length; i++) {
            if (phone.value![i] == ' ') {
              continue;
            }
            num += phone.value![i];
          }
          if (num.length > 10) {
            num = num.substring(num.length - 10);
          }
          cc.add(num);
        }
      }
    }
    // prefs.setString('numbers', jsonEncode(cc));
    setState(() {
      contacts = ccc;
      numbers = cc;
    });
    await fetchFriends();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: api_fetching ? friends.length + 1 : friends.length,
            itemBuilder: ((context, idx) {
              if (api_fetching && idx == 0) {
                return ApiLoader();
              }
              int index = api_fetching ? idx - 1 : idx;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[800]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                              "assets/profile/${friends[index].dp}.png"),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            friends[index].name,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            friends[index].email,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            friends[index].country_code +
                                " " +
                                friends[index].phone,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Future<void> fetchFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    var data = await postRequest(
        "${url!}/auth/get-friends",
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        jsonEncode({"contacts": numbers}),
        prefs,
        context);
    if (data != null) {
      if (data['status'] == 200) {
        var users = data['friends'];
        List<UserModel> temp = [];
        users.forEach((user) => {temp.add(UserModel.fromJson(user))});
        var userBox = Boxes.getUsers();
        var localUsers = userBox.values.toList();
        for (var user in localUsers) {
          if (!temp.contains(user)) {
            userBox.delete(user.id);
          }
        }
        for (var user in temp) {
          await userBox.put(user.id, user);
        }
        setState(() {
          loading = false;
          friends = temp;
          api_fetching = false;
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
      api_fetching = false;
    });
  }
}
