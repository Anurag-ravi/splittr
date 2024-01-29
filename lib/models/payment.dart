class PaymentModel {
  String _id;
  String trip;
  double amount;
  DateTime created;
  String by;
  String to;

  PaymentModel(
      this._id, this.trip, this.amount, this.created, this.by, this.to);

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      json['_id'],
      json['trip'],
      json['amount'],
      json['created'],
      json['by'] + 0.0,
      json['to'] + 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'trip': trip,
      'amount': amount,
      'created': created,
      'by': by,
      'to': to,
    };
  }
}
