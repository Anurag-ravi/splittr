import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/payments/domain/entities/payment_entity.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@HiveType(typeId: 2)
@freezed
class PaymentModel with _$PaymentModel {
  const PaymentModel._();

  const factory PaymentModel({
    @HiveField(0) @JsonKey(name: '_id') required String id,
    @HiveField(1) required String trip,
    @HiveField(2) required double amount,
    @HiveField(3) required DateTime created,
    @HiveField(4) required String by,
    @HiveField(5) required String to,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  PaymentEntity toEntity() => PaymentEntity(
        id: id,
        tripId: trip,
        amount: amount,
        created: created,
        byMemberId: by,
        toMemberId: to,
      );

  static PaymentModel fromEntity(PaymentEntity e) => PaymentModel(
        id: e.id,
        trip: e.tripId,
        amount: e.amount,
        created: e.created,
        by: e.byMemberId,
        to: e.toMemberId,
      );
}
