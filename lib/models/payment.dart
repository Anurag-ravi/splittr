class PaymentModel {
  String id;
  String trip;
  double amount;
  DateTime created;
  String by;
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
