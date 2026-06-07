import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';

part 'split_entry_model.freezed.dart';
part 'split_entry_model.g.dart';

@HiveType(typeId: 4)
@freezed
class SplitEntryModel with _$SplitEntryModel {
  const SplitEntryModel._();

  const factory SplitEntryModel({
    @HiveField(0) required String user,
    @HiveField(1) required double amount,
    @HiveField(2) @JsonKey(name: 'share_or_percent') @Default(0.0) double shareOrPercent,
  }) = _SplitEntryModel;

  factory SplitEntryModel.fromJson(Map<String, dynamic> json) =>
      _$SplitEntryModelFromJson(json);

  SplitEntryEntity toEntity() => SplitEntryEntity(
        memberId: user,
        amount: amount,
        shareOrPercent: shareOrPercent,
      );

  static SplitEntryModel fromEntity(SplitEntryEntity e) => SplitEntryModel(
        user: e.memberId,
        amount: e.amount,
        shareOrPercent: e.shareOrPercent,
      );
}
