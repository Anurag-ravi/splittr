import 'package:equatable/equatable.dart';

/// Represents one entry in paidBy or paidFor — who and how much.
class SplitEntryEntity extends Equatable {
  const SplitEntryEntity({
    required this.memberId,
    required this.amount,
    this.shareOrPercent = 0,
  });

  final String memberId;
  final double amount;
  final double shareOrPercent;

  SplitEntryEntity copyWith({
    String? memberId,
    double? amount,
    double? shareOrPercent,
  }) =>
      SplitEntryEntity(
        memberId: memberId ?? this.memberId,
        amount: amount ?? this.amount,
        shareOrPercent: shareOrPercent ?? this.shareOrPercent,
      );

  @override
  List<Object?> get props => [memberId, amount, shareOrPercent];
}
