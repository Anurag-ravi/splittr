import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';

// UI-only value objects used by expense picker screens.
// Not Hive-stored — pure in-memory.

typedef splitTypeEnum = SplitType;

class By {
  String user;
  double amount;
  double share_or_percent;

  By(this.user, this.amount, this.share_or_percent);

  @override
  String toString() => 'By{user: $user, amount: $amount}';
}

class ByEqual {
  String user;
  bool involved;

  ByEqual(this.user, this.involved);
}

class ByShare {
  String user;
  int share;

  ByShare(this.user, this.share);
}
