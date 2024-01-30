import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/tripuser.dart';

class ShortTripModel {
  String name;
  String id;

  ShortTripModel({required this.name, required this.id});

  factory ShortTripModel.fromJson(Map<String, dynamic> json) {
    return ShortTripModel(
      name: json['name'],
      id: json['_id'],
    );
  }
}

class TripModel {
  String id;
  String code;
  String name;
  DateTime created;
  String currency;
  String created_by;
  List<TripUser> users;
  List<ExpenseModel> expenses;
  List<PaymentModel> payments;

  TripModel(this.id, this.code, this.name, this.created, this.currency,
      this.created_by, this.users, this.expenses, this.payments);

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // print(json);
    return TripModel(
      json['_id'],
      json['code'],
      json['name'],
      DateTime.parse(json['created']),
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
  bool isExpense;
  DateTime date;
  ExpenseModel? expense;
  PaymentModel? payment;

  Transaction(this.isExpense, this.date, this.expense, this.payment);
}
