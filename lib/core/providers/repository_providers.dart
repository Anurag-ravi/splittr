import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/shared/repositories/repositories.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(sharedPreferencesProvider));
});

final tripRepositoryProvider = Provider<TripRepository>((_) {
  return const TripRepository();
});

final commentRepositoryProvider = Provider<CommentRepository>((_) {
  return const CommentRepository();
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((_) {
  return const ExpenseRepository();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((_) {
  return const PaymentRepository();
});

final friendsRepositoryProvider = Provider<FriendsRepository>((_) {
  return const FriendsRepository();
});

final activityRepositoryProvider = Provider<ActivityRepository>((_) {
  return const ActivityRepository();
});
