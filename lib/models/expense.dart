import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
enum splitTypeEnum {
  @HiveField(0)
  equal,
  @HiveField(1)
  unequal,
  @HiveField(2)
  shares,
  @HiveField(3)
  percent
}

@HiveType(typeId: 5)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String trip;

  @HiveField(2)
  String name;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String category;

  @HiveField(5)
  splitTypeEnum splitType;

  @HiveField(6)
  DateTime created;

  @HiveField(7)
  List<By> paid_by;

  @HiveField(8)
  List<By> paid_for;

  ExpenseModel(this.id, this.trip, this.name, this.amount, this.category,
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
        DateTime.parse(json['created']).toLocal(),
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
    json['_id'] = this.id;
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

  @override
  String toString() {
    return 'ExpenseModel{id: $id, name: $name, amount: $amount, category: $category, splitType: $splitType, created: $created, paid_by: $paid_by, paid_for: $paid_for}';
  }
}

@HiveType(typeId: 4)
class By extends HiveObject {
  @HiveField(0)
  String user;

  @HiveField(1)
  double amount;

  @HiveField(2)
  double share_or_percent;

  By(this.user, this.amount, this.share_or_percent);

  factory By.fromJson(Map<String, dynamic> json) {
    if (json['share_or_percent'] != null)
      return By(
          json['user'], json['amount'] + 0.0, json['share_or_percent'] + 0.0);
    return By(json['user'], json['amount'] + 0.0, 0.0);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'user': user, 'amount': amount};
    if (share_or_percent > 0.0) json['share_or_percent'] = share_or_percent;
    return json;
  }

  @override
  String toString() {
    return 'By{user: $user, amount: $amount}';
  }
}

class ByEqual {
  String user;
  bool involved;

  ByEqual(this.user, this.involved);

  @override
  String toString() {
    return 'By{user: $user, involved: $involved}';
  }
}

class ByShare {
  String user;
  int share;

  ByShare(this.user, this.share);

  @override
  String toString() {
    return 'By{user: $user, share: $share}';
  }
}
