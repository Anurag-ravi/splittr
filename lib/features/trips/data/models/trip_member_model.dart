import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/trips/domain/entities/trip_member_entity.dart';

part 'trip_member_model.freezed.dart';
part 'trip_member_model.g.dart';

@HiveType(typeId: 1)
@freezed
class TripMemberModel with _$TripMemberModel {
  const TripMemberModel._();

  const factory TripMemberModel({
    @HiveField(0) @JsonKey(name: '_id') required String id,
    @HiveField(1) required String trip,
    @HiveField(2) required String user,
    @HiveField(3) required String name,
    @HiveField(4) required String dp,
    @HiveField(5) required bool involved,
  }) = _TripMemberModel;

  factory TripMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TripMemberModelFromJson(json);

  TripMemberEntity toEntity() => TripMemberEntity(
        id: id,
        tripId: trip,
        userId: user,
        name: name,
        dp: dp,
        involved: involved,
      );

  static TripMemberModel fromEntity(TripMemberEntity e) => TripMemberModel(
        id: e.id,
        trip: e.tripId,
        user: e.userId,
        name: e.name,
        dp: e.dp,
        involved: e.involved,
      );
}
