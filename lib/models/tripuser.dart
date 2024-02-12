class TripUser {
  String id;
  String trip;
  String user;
  String name;
  String dp;
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
}
