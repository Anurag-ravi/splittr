import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/firebase_options.dart';
import 'package:splittr/pages/login.dart';

late SharedPreferences prefs;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs,));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool theme = false;
  void updateTheme(bool val){
    setState(() {
      theme = val;
    });
    prefs.setBool("theme", val);
  } 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    theme = widget.prefs.getBool("theme")?? false;
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if(!widget.prefs.containsKey("theme")){
      widget.prefs.setBool("theme", true);
    }
    return MaterialApp(
      title: 'Splittr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
        
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      ),
      themeMode: theme ? ThemeMode.light : ThemeMode.dark,
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
