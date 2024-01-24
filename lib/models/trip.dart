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
