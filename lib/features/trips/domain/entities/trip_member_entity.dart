import 'package:equatable/equatable.dart';

class TripMemberEntity extends Equatable {
  const TripMemberEntity({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.name,
    required this.dp,
    required this.involved,
  });

  final String id;
  final String tripId;
  final String userId;
  final String name;
  final String dp;
  final bool involved;

  TripMemberEntity copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? name,
    String? dp,
    bool? involved,
  }) =>
      TripMemberEntity(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        dp: dp ?? this.dp,
        involved: involved ?? this.involved,
      );

  @override
  List<Object?> get props => [id, tripId, userId, name, dp, involved];
}
