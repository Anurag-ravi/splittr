import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 2)
class PaymentModel extends HiveObject{
  @HiveField(0)
  String id;

  @HiveField(1)
  String trip;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime created;

  @HiveField(4)
  String by;

  @HiveField(5)
  String to;

  PaymentModel(this.id, this.trip, this.amount, this.created, this.by, this.to);

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      json['_id'],
      json['trip'],
      json['amount'] + 0.0,
      DateTime.parse(json['created']).toLocal(),
      json['by'],
      json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'trip': trip,
      'amount': amount,
      'created': created,
      'by': by,
      'to': to,
    };
  }
}
