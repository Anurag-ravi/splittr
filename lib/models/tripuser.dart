class TripUser {
  String _id;
  String trip;
  String user;
  String name;
  double paid;
  double owed;
  bool is_involved;

  TripUser(this._id, this.trip, this.user, this.name, this.paid, this.owed,
      this.is_involved);

  factory TripUser.fromJson(Map<String, dynamic> json) {
    return TripUser(json['_id'], json['trip'], json['user'], json['name'],
        json['paid'], json['owed'], json['is_involved']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _id;
    data['trip'] = trip;
    data['user'] = user;
    data['name'] = name;
    data['paid'] = paid;
    data['owed'] = owed;
    data['is_involved'] = is_involved;
    return data;
  }
}
