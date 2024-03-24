import 'package:hive/hive.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/tripuser.dart';

part 'trip.g.dart';

@HiveType(typeId: 6)
class ShortTripModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String id;

  ShortTripModel({required this.name, required this.id});

  factory ShortTripModel.fromJson(Map<String, dynamic> json) {
    return ShortTripModel(
      name: json['name'],
      id: json['_id'],
    );
  }
}

@HiveType(typeId: 7)
class TripModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String code;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime created;

  @HiveField(4)
  String currency;

  @HiveField(5)
  String created_by;

  @HiveField(6)
  List<TripUser> users;

  @HiveField(7)
  List<ExpenseModel> expenses;

  @HiveField(8)
  List<PaymentModel> payments;

  TripModel(this.id, this.code, this.name, this.created, this.currency,
      this.created_by, this.users, this.expenses, this.payments);

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      json['_id'],
      json['code'],
      json['name'],
      DateTime.parse(json['created']).toLocal(),
      json['currency'],
      json['created_by'],
      List<TripUser>.from(json['users'].map((x) => TripUser.fromJson(x))),
      List<ExpenseModel>.from(
          json['expenses'].map((x) => ExpenseModel.fromJson(x))),
      List<PaymentModel>.from(
          json['payments'].map((x) => PaymentModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
      'created': created.toIso8601String(),
      'currency': currency,
      'created_by': created_by,
      'users': List<dynamic>.from(users.map((x) => x.toJson())),
      'expenses': List<dynamic>.from(expenses.map((x) => x.toJson())),
      'payments': List<dynamic>.from(payments.map((x) => x.toJson())),
    };
  }
}

class Transaction {
  bool isMonth;
  String month;
  bool isExpense;
  bool isLoading;
  DateTime date;
  ExpenseModel? expense;
  PaymentModel? payment;

  Transaction(this.isExpense, this.date, this.expense, this.payment,
      {this.isMonth = false, this.month = "", this.isLoading = false});
}
