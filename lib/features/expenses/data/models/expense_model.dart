import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 5)
@freezed
class ExpenseModel with _$ExpenseModel {
  const ExpenseModel._();

  const factory ExpenseModel({
    @HiveField(0) @JsonKey(name: '_id') required String id,
    @HiveField(1) required String trip,
    @HiveField(2) required String name,
    @HiveField(3) required double amount,
    @HiveField(4) required String category,
    @HiveField(5) @JsonKey(name: 'split_type') required String splitType,
    @HiveField(6) required DateTime created,
    @HiveField(7) @JsonKey(name: 'paid_by') required List<SplitEntryModel> paidBy,
    @HiveField(8) @JsonKey(name: 'paid_for') required List<SplitEntryModel> paidFor,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  SplitType get splitTypeEnum => switch (splitType) {
        'unequal' => SplitType.unequal,
        'shares' => SplitType.shares,
        'percent' => SplitType.percent,
        _ => SplitType.equal,
      };

  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        tripId: trip,
        name: name,
        amount: amount,
        category: category,
        splitType: splitTypeEnum,
        created: created,
        paidBy: paidBy.map((e) => e.toEntity()).toList(),
        paidFor: paidFor.map((e) => e.toEntity()).toList(),
      );

  static ExpenseModel fromEntity(ExpenseEntity e) => ExpenseModel(
        id: e.id,
        trip: e.tripId,
        name: e.name,
        amount: e.amount,
        category: e.category,
        splitType: e.splitType.name,
        created: e.created,
        paidBy: e.paidBy.map(SplitEntryModel.fromEntity).toList(),
        paidFor: e.paidFor.map(SplitEntryModel.fromEntity).toList(),
      );
}
