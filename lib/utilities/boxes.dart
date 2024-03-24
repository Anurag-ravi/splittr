import 'package:hive/hive.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/models/user.dart';

class Boxes {
  static Box<ExpenseModel> getExpenses() => Hive.box<ExpenseModel>('expenses');

  static Box<PaymentModel> getPayments() => Hive.box<PaymentModel>('payments');

  static Box<ShortTripModel> getShortTrips() =>
      Hive.box<ShortTripModel>('shorttrips');

  static Box<TripModel> getTrips() => Hive.box<TripModel>('trips');

  static Box<TripUser> getTripUsers() => Hive.box<TripUser>('tripusers');

  static Box<UserModel> getUsers() => Hive.box<UserModel>('users');

  static Box<UserModel> getMe() => Hive.box<UserModel>('me');
}
