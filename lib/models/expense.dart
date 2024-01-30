enum splitTypeEnum { equal, unequal, percent, shares }

class ExpenseModel {
  String _id;
  String trip;
  String name;
  double amount;
  String category;
  splitTypeEnum splitType;
  DateTime created;
  List<By> paid_by;
  List<By> paid_for;

  ExpenseModel(this._id, this.trip, this.name, this.amount, this.category,
      this.splitType, this.created, this.paid_by, this.paid_for);

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    List<By> paid_by = [];
    List<By> paid_for = [];
    if (json['paid_by'] != null) {
      json['paid_by'].forEach((paid_by_json) {
        paid_by.add(By.fromJson(paid_by_json));
      });
    }
    if (json['paid_for'] != null) {
      json['paid_for'].forEach((paid_for_json) {
        paid_for.add(By.fromJson(paid_for_json));
      });
    }
    splitTypeEnum x = splitTypeEnum.equal;
    if (json['split_type'] == "unequal") x = splitTypeEnum.unequal;
    if (json['split_type'] == "percent") x = splitTypeEnum.percent;
    if (json['split_type'] == "shares") x = splitTypeEnum.shares;
    return ExpenseModel(
        json['_id'],
        json['trip'],
        json['name'],
        json['amount'] + 0.0,
        json['category'],
        x,
        json['created'],
        paid_by,
        paid_for);
  }
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> paid_by_json = [];
    List<Map<String, dynamic>> paid_for_json = [];
    paid_by.forEach((paid_by_item) {
      paid_by_json.add(paid_by_item.toJson());
    });
    paid_for.forEach((paid_for_item) {
      paid_for_json.add(paid_for_item.toJson());
    });
    Map<String, dynamic> json = new Map<String, dynamic>();
    json['_id'] = this._id;
    json['trip'] = this.trip;
    json['name'] = this.name;
    json['amount'] = this.amount;
    json['category'] = this.category;
    json['split_type'] = this.splitType.name;
    json['created'] = this.created;
    json['paid_by'] = paid_by_json;
    json['paid_for'] = paid_for_json;
    return json;
  }
}

class By {
  String user;
  double amount;

  By(this.user, this.amount);

  factory By.fromJson(Map<String, dynamic> json) {
    return By(json['user'], json['amount'] + 0.0);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'user': user, 'amount': amount};
    return json;
  }
}
