import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/firebase_options.dart';
import 'package:splittr/pages/completeSignup.dart';
import 'package:splittr/pages/homePage.dart';
import 'package:splittr/pages/login.dart';
import 'package:splittr/utilities/activity_navigator.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

// import all typeAdapter files
import 'package:splittr/models/comment.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> setupPushNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
  String? token = await messaging.getToken();
  if (token != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('fcm_token');
    String? authToken = prefs.getString('token');
    if (authToken != null) {
      if (storedToken != null && storedToken != token) {
        await updateFcmToken('remove', storedToken);
      }
      await updateFcmToken('add', token);
    }
    await prefs.setString('fcm_token', token);
  }

  messaging.onTokenRefresh.listen((newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('fcm_token');
    String? authToken = prefs.getString('token');
    if (authToken != null) {
      if (storedToken != null) {
        await updateFcmToken('remove', storedToken);
      }
      await updateFcmToken('add', newToken);
    }
    await prefs.setString('fcm_token', newToken);
  });
}

late SharedPreferences prefs;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupPushNotifications();

  prefs = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  // register all typeAdapters
  Hive.registerAdapter(CommentModelAdapter());
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
    _setupInteractedMessage();
  }

  // 3. Handle the interactions
  Future<void> _setupInteractedMessage() async {
    // State A: App is Terminated, user clicks notification to launch
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }

    // State B: App is in Background, user clicks notification to bring to foreground
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${message.notification?.title}: ${message.notification?.body ?? ''}"),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => _handleMessageClick(message),
            ),
          ),
        );
      }
    });
  }

  void _handleMessageClick(RemoteMessage message) {
    // Extract your custom data payload
    final data = message.data;
    final String? entityId = data['entity_id'];
    final String? entityType = data['entity_type'];

    if (entityId != null && entityType != null) {
      // Use the global key to get the context safely
      final context = navigatorKey.currentContext;
      
      if (context != null) {
        ActivityNavigator.navigate(context, entityId, entityType);
      } else {
        print("Error: Context is null, cannot navigate.");
        // Note: If context is null here (rare but possible on cold starts), 
        // you might need to save the route intent in SharedPreferences or a 
        // Provider/Bloc and execute it immediately after the first screen builds.
      }
    }
  }

  void FetchContacts() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
      if (await Permission.storage.isPermanentlyDenied) {
        var snackBar = const SnackBar(
          content: Text(
              "Grant storage permission from settings to export excel files"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await Future.delayed(const Duration(seconds: 2));
        openAppSettings();
      }
      if (!await Permission.storage.isGranted) {
        var snackBar = const SnackBar(
          content:
              Text("Without Storage permission, you can't export excel files"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    if (!await Permission.contacts.isGranted) {
      await Permission.contacts.request();
      if (await Permission.contacts.isPermanentlyDenied) {
        var snackBar = const SnackBar(
          content:
              Text("Grant contacts permission from settings to view friends"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await Future.delayed(const Duration(seconds: 2));
        openAppSettings();
      }
      if (!await Permission.contacts.isGranted) {
        var snackBar = const SnackBar(
          content: Text("Without contacts, you can't view friends"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    List<Contact> ccc = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );

    List<String> cc = [];

    for (var contact in ccc) {
      for (var phone in contact.phones) {
        String num = phone.number.replaceAll(' ', '');

        if (num.length > 10) {
          num = num.substring(num.length - 10);
        }

        cc.add(num);
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
      navigatorKey: navigatorKey,
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
              : const HomePage(
                  curridx: 0,
                )
          : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
