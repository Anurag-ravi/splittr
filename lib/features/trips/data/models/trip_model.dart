import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/domain/entities/trip_entity.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@HiveType(typeId: 6)
@freezed
class ShortTripModel with _$ShortTripModel {
  const ShortTripModel._();

  const factory ShortTripModel({
    @HiveField(1) @JsonKey(name: '_id') required String id,
    @HiveField(0) required String name,
  }) = _ShortTripModel;

  factory ShortTripModel.fromJson(Map<String, dynamic> json) =>
      _$ShortTripModelFromJson(json);

  ShortTripEntity toEntity() => ShortTripEntity(id: id, name: name);
}

@HiveType(typeId: 7)
@freezed
class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    @HiveField(0) @JsonKey(name: '_id') required String id,
    @HiveField(1) required String code,
    @HiveField(2) required String name,
    @HiveField(3) required DateTime created,
    @HiveField(4) required String currency,
    @HiveField(5) @JsonKey(name: 'created_by') required String createdBy,
    @HiveField(6) required List<TripMemberModel> users,
    @HiveField(7) required List<ExpenseModel> expenses,
    @HiveField(8) required List<PaymentModel> payments,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  TripEntity toEntity() => TripEntity(
        id: id,
        code: code,
        name: name,
        created: created,
        currency: currency,
        createdBy: createdBy,
        members: users.map((u) => u.toEntity()).toList(),
        expenses: expenses.map((e) => e.toEntity()).toList(),
        payments: payments.map((p) => p.toEntity()).toList(),
      );
}
