import 'package:hive/hive.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

/// Typed accessors for every Hive box. All box names live in AppConstants.
abstract final class HiveBoxes {
  static Box<ExpenseModel> get expenses =>
      Hive.box<ExpenseModel>(AppConstants.hiveBoxExpenses);

  static Box<PaymentModel> get payments =>
      Hive.box<PaymentModel>(AppConstants.hiveBoxPayments);

  static Box<ShortTripModel> get shortTrips =>
      Hive.box<ShortTripModel>(AppConstants.hiveBoxShortTrips);

  static Box<TripModel> get trips =>
      Hive.box<TripModel>(AppConstants.hiveBoxTrips);

  static Box<TripMemberModel> get tripUsers =>
      Hive.box<TripMemberModel>(AppConstants.hiveBoxTripUsers);

  static Box<UserModel> get users =>
      Hive.box<UserModel>(AppConstants.hiveBoxUsers);

  static Box<UserModel> get me =>
      Hive.box<UserModel>(AppConstants.hiveBoxMe);
}
