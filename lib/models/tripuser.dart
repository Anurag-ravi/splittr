class TripUser {
  String id;
  String trip;
  String user;
  String name;
  double paid;
  double owed;
  bool is_involved;

  TripUser(this.id, this.trip, this.user, this.name, this.paid, this.owed,
      this.is_involved);

  factory TripUser.fromJson(Map<String, dynamic> json) {
    return TripUser(json['_id'], json['trip'], json['user'], json['name'],
        json['paid'] + 0.0, json['owed'] + 0.0, json['is_involved']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['trip'] = trip;
    data['user'] = user;
    data['name'] = name;
    data['paid'] = paid;
    data['owed'] = owed;
    data['is_involved'] = is_involved;
    return data;
  }
}
