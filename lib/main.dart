import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/providers/theme_provider.dart';
import 'package:splittr/core/theme/app_theme.dart';
import 'package:splittr/firebase_options.dart';
import 'package:splittr/features/auth/presentation/screens/complete_signup_screen.dart';
import 'package:splittr/features/auth/presentation/screens/login_screen.dart';
import 'package:splittr/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/features/trips/presentation/screens/add_to_group_screen.dart';
import 'package:splittr/features/trips/presentation/screens/remove_from_group_screen.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/core/services/home_widget_service.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splittr/shared/services/activity_navigator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message: ${message.messageId}');
}

Future<void> _setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission();
  if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

  final token = await messaging.getToken();
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.prefKeyFcmToken);
    if (stored != null && stored != token) {
      await _updateFcmToken('remove', stored);
    }
    await _updateFcmToken('add', token);
    await prefs.setString(AppConstants.prefKeyFcmToken, token);
  }

  messaging.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.prefKeyFcmToken);
    if (stored != null) await _updateFcmToken('remove', stored);
    await _updateFcmToken('add', newToken);
    await prefs.setString(AppConstants.prefKeyFcmToken, newToken);
  });
}

Future<void> _updateFcmToken(String action, String fcmToken) async {
  try {
    await AppHttpClient.postNoContext(
        '/auth/fcm-token', {'token': fcmToken, 'action': action});
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _setupPushNotifications();

  await Hive.initFlutter();
  Hive.registerAdapter(CommentModelAdapter());
  Hive.registerAdapter(SplitEntryModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  Hive.registerAdapter(ShortTripModelAdapter());
  Hive.registerAdapter(TripMemberModelAdapter());
  Hive.registerAdapter(TripModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<ExpenseModel>(AppConstants.hiveBoxExpenses);
  await Hive.openBox<PaymentModel>(AppConstants.hiveBoxPayments);
  await Hive.openBox<ShortTripModel>(AppConstants.hiveBoxShortTrips);
  await Hive.openBox<TripModel>(AppConstants.hiveBoxTrips);
  await Hive.openBox<TripMemberModel>(AppConstants.hiveBoxTripUsers);
  await Hive.openBox<UserModel>(AppConstants.hiveBoxUsers);
  await Hive.openBox<UserModel>(AppConstants.hiveBoxMe);

  FlutterError.onError = FlutterError.dumpErrorToConsole;

  ErrorWidget.builder = (details) => Material(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              details.exception.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );

  final prefs = await SharedPreferences.getInstance();
  // Ensure URL is always set
  prefs.setString(AppConstants.prefKeyUrl, AppConstants.baseUrl);
  if (!prefs.containsKey(AppConstants.prefKeyRegisteredNow)) {
    prefs.setBool(AppConstants.prefKeyRegisteredNow, true);
  }
  prefs.setBool(AppConstants.prefKeyUpdate, true);
  prefs.setBool(AppConstants.prefKeyFirstLoad, true);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: SplittrApp(prefs: prefs),
    ),
  );
}

class SplittrApp extends ConsumerStatefulWidget {
  const SplittrApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  ConsumerState<SplittrApp> createState() => _SplittrAppState();
}

class _SplittrAppState extends ConsumerState<SplittrApp> {
  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _setupFcmHandlers();
    _setupHomeWidget();
  }

  void _setupHomeWidget() {
    HomeWidgetService.initialize(
      onDeepLink: (uri) {
        if (uri != 'splittr://add-expense') return;
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        final trips = HiveBoxes.trips.values.toList();
        if (trips.isEmpty) return;
        Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(trip: trips.first),
          ),
        );
      },
    );
  }

  Future<void> _setupFcmHandlers() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    final ctx = navigatorKey.currentContext;
    if (initial != null && ctx != null) _handleMessageClick(initial);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
  }

  void _handleMessageClick(RemoteMessage message) {
    final entityId = message.data['entity_id'] as String?;
    final entityType = message.data['entity_type'] as String?;
    if (entityId == null || entityType == null) return;
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ActivityNavigator.navigate(ctx, entityId, entityType);
    }
  }

  Future<void> _fetchContacts() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.contacts.isGranted) {
      await Permission.contacts.request();
      if (!await Permission.contacts.isGranted) return;
    }
    final contacts =
        await FlutterContacts.getAll(properties: {ContactProperty.phone});
    final numbers = <String>[];
    for (final c in contacts) {
      for (final p in c.phones) {
        String num = p.number.replaceAll(' ', '');
        if (num.length > 10) num = num.substring(num.length - 10);
        numbers.add(num);
      }
    }
    widget.prefs.setString(AppConstants.prefKeyNumbers, jsonEncode(numbers));
  }

  Widget get _home {
    final onboardingDone =
        widget.prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;
    final token = widget.prefs.getString(AppConstants.prefKeyToken);
    final registeredNow =
        widget.prefs.getBool(AppConstants.prefKeyRegisteredNow) ?? true;
    final email = widget.prefs.getString(AppConstants.prefKeyEmail) ?? '';

    if (!onboardingDone) return const OnboardingScreen();
    if (token == null) return const LoginScreen();
    if (registeredNow) return CompleteSignUpScreen(email: email);
    return const HomeScreen(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Splittr',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
      home: _home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/add-to-group':
            return MaterialPageRoute(
              builder: (_) =>
                  AddToGroupScreen(trip: settings.arguments as TripModel),
            );
          case '/remove-from-group':
            return MaterialPageRoute(
              builder: (_) =>
                  RemoveFromGroupScreen(trip: settings.arguments as TripModel),
            );
          default:
            return null;
        }
      },
    );
  }
}
