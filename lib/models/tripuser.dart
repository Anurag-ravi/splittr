import 'package:hive/hive.dart';

part 'tripuser.g.dart';

@HiveType(typeId: 1)
class TripUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String trip;

  @HiveField(2)
  String user;

  @HiveField(3)
  String name;

  @HiveField(4)
  String dp;

  @HiveField(5)
  bool involved;

  TripUser(this.id, this.trip, this.user, this.name, this.dp, this.involved);

  factory TripUser.fromJson(Map<String, dynamic> json) {
    return TripUser(json['_id'], json['trip'], json['user'], json['name'],
        json['dp'], json['involved']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['trip'] = trip;
    data['user'] = user;
    data['name'] = name;
    data['dp'] = dp;
    data['involved'] = involved;
    return data;
  }

  @override
  String toString() {
    return 'TripUser{id: $id, name: $name, involved: $involved}';
  }
}
