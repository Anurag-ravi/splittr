import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/firebase_options.dart';
import 'package:splittr/pages/completeSignup.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/pages/login.dart';
import 'package:splittr/utilities/constants.dart';

// import all typeAdapter files
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';

late SharedPreferences prefs;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  prefs = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  // register all typeAdapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(splitTypeEnumAdapter());
  Hive.registerAdapter(ByAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  Hive.registerAdapter(ShortTripModelAdapter());
  Hive.registerAdapter(TripModelAdapter());
  Hive.registerAdapter(TripUserAdapter());
  Hive.registerAdapter(UserModelAdapter());
  // open all boxes
  await Hive.openBox<ExpenseModel>('expenses');
  await Hive.openBox<PaymentModel>('payments');
  await Hive.openBox<ShortTripModel>('shorttrips');
  await Hive.openBox<TripModel>('trips');
  await Hive.openBox<TripUser>('tripusers');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<UserModel>('me');

  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool theme = false;
  void updateTheme(bool val) {
    setState(() {
      theme = val;
    });
    prefs.setBool("theme", val);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    theme = false;
    FetchContacts();
    widget.prefs.setBool("update", true);
    widget.prefs.setBool("first_load", true);
  }

  void FetchContacts() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
      if (await Permission.storage.isPermanentlyDenied) {
        var snackBar = SnackBar(
          content: Text(
              "Grant storage permission from settings to export excel files"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await Future.delayed(Duration(seconds: 2));
        openAppSettings();
      }
      if (!await Permission.storage.isGranted) {
        var snackBar = SnackBar(
          content:
              Text("Without Storage permission, you can't export excel files"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    if (!await Permission.contacts.isGranted) {
      await Permission.contacts.request();
      if (await Permission.contacts.isPermanentlyDenied) {
        var snackBar = SnackBar(
          content:
              Text("Grant contacts permission from settings to view friends"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await Future.delayed(Duration(seconds: 2));
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('numbers', jsonEncode(cc));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // widget.prefs.setString("url", "http://10.0.2.2:5000");
    widget.prefs.setString("url", "https://splittr-backend.onrender.com");
    if (!widget.prefs.containsKey("registered_now")) {
      widget.prefs.setBool("registered_now", true);
    }
    String email = '';
    if (widget.prefs.containsKey('email')) {
      email = widget.prefs.getString('email')!;
    }
    return MaterialApp(
      title: 'Splittr',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
      darkTheme: ThemeData(
          // brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: mainGreen),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
      themeMode: ThemeMode.dark,
      home: widget.prefs.getString('token') != null
          ? widget.prefs.getBool('registered_now')!
              ? CompleteSignUp(
                  email: email,
                )
              : HomePage(
                  curridx: 0,
                )
          : LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
