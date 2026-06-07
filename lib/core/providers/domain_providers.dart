import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';

// ── Features
import 'package:splittr/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:splittr/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:splittr/features/activity/domain/repositories/activity_repository.dart';
import 'package:splittr/features/activity/domain/usecases/activity_usecases.dart';
import 'package:splittr/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:splittr/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:splittr/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';
import 'package:splittr/features/auth/domain/usecases/logout_usecase.dart';
import 'package:splittr/features/auth/domain/usecases/oauth_login_usecase.dart';
import 'package:splittr/features/auth/domain/usecases/register_usecase.dart';
import 'package:splittr/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:splittr/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:splittr/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:splittr/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:splittr/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:splittr/features/expenses/domain/repositories/expense_repository.dart';
import 'package:splittr/features/expenses/domain/usecases/expense_usecases.dart';
import 'package:splittr/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:splittr/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:splittr/features/friends/domain/repositories/friends_repository.dart';
import 'package:splittr/features/friends/domain/usecases/fetch_friends_usecase.dart';
import 'package:splittr/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:splittr/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:splittr/features/payments/domain/repositories/payment_repository.dart';
import 'package:splittr/features/payments/domain/usecases/payment_usecases.dart';
import 'package:splittr/features/trips/data/datasources/trip_local_datasource.dart';
import 'package:splittr/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:splittr/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:splittr/features/trips/domain/repositories/trip_repository.dart';
import 'package:splittr/features/trips/domain/usecases/fetch_trips_usecase.dart';
import 'package:splittr/features/trips/domain/usecases/mutate_trip_usecases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure
// ─────────────────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiClient(
    baseUrl: prefs.getString(AppConstants.prefKeyUrl) ?? AppConstants.baseUrl,
    tokenProvider: () => prefs.getString(AppConstants.prefKeyToken),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth
// ─────────────────────────────────────────────────────────────────────────────

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) =>
    AuthRemoteDatasource(ref.watch(apiClientProvider)));

final authLocalDatasourceProvider = Provider<IAuthLocalDatasource>((ref) =>
    AuthLocalDatasource(ref.watch(sharedPreferencesProvider)));

final authRepositoryProvider = Provider<IAuthRepository>((ref) =>
    AuthRepositoryImpl(
      remote: ref.watch(authRemoteDatasourceProvider),
      local: ref.watch(authLocalDatasourceProvider),
    ));

final requestOtpUseCaseProvider =
    Provider((ref) => RequestOtpUseCase(ref.watch(authRepositoryProvider)));
final verifyOtpUseCaseProvider =
    Provider((ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)));
final oauthLoginUseCaseProvider =
    Provider((ref) => OAuthLoginUseCase(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider =
    Provider((ref) => RegisterUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider =
    Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final updateProfileUseCaseProvider =
    Provider((ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)));

// ─────────────────────────────────────────────────────────────────────────────
// Trips
// ─────────────────────────────────────────────────────────────────────────────

final tripRemoteDatasourceProvider = Provider<ITripRemoteDatasource>((ref) =>
    TripRemoteDatasource(ref.watch(apiClientProvider)));

final tripLocalDatasourceProvider = Provider<ITripLocalDatasource>(
    (_) => const TripLocalDatasource());

final tripRepositoryProvider = Provider<ITripRepository>((ref) =>
    TripRepositoryImpl(
      remote: ref.watch(tripRemoteDatasourceProvider),
      local: ref.watch(tripLocalDatasourceProvider),
    ));

final fetchAllTripsUseCaseProvider =
    Provider((ref) => FetchAllTripsUseCase(ref.watch(tripRepositoryProvider)));
final fetchTripUseCaseProvider =
    Provider((ref) => FetchTripUseCase(ref.watch(tripRepositoryProvider)));
final createTripUseCaseProvider =
    Provider((ref) => CreateTripUseCase(ref.watch(tripRepositoryProvider)));
final joinTripUseCaseProvider =
    Provider((ref) => JoinTripUseCase(ref.watch(tripRepositoryProvider)));
final editTripNameUseCaseProvider =
    Provider((ref) => EditTripNameUseCase(ref.watch(tripRepositoryProvider)));
final leaveTripUseCaseProvider =
    Provider((ref) => LeaveTripUseCase(ref.watch(tripRepositoryProvider)));
final deleteTripUseCaseProvider =
    Provider((ref) => DeleteTripUseCase(ref.watch(tripRepositoryProvider)));
final addMembersUseCaseProvider =
    Provider((ref) => AddMembersUseCase(ref.watch(tripRepositoryProvider)));
final removeMembersUseCaseProvider =
    Provider((ref) => RemoveMembersUseCase(ref.watch(tripRepositoryProvider)));

// ─────────────────────────────────────────────────────────────────────────────
// Expenses
// ─────────────────────────────────────────────────────────────────────────────

final expenseRemoteDatasourceProvider = Provider<IExpenseRemoteDatasource>(
    (ref) => ExpenseRemoteDatasource(ref.watch(apiClientProvider)));

final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) =>
    ExpenseRepositoryImpl(ref.watch(expenseRemoteDatasourceProvider)));

final saveExpenseUseCaseProvider =
    Provider((ref) => SaveExpenseUseCase(ref.watch(expenseRepositoryProvider)));
final deleteExpenseUseCaseProvider =
    Provider((ref) => DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider)));
final fetchExpenseCommentsUseCaseProvider = Provider(
    (ref) => FetchExpenseCommentsUseCase(ref.watch(expenseRepositoryProvider)));
final postExpenseCommentUseCaseProvider = Provider(
    (ref) => PostExpenseCommentUseCase(ref.watch(expenseRepositoryProvider)));
final deleteExpenseCommentUseCaseProvider = Provider(
    (ref) => DeleteExpenseCommentUseCase(ref.watch(expenseRepositoryProvider)));

// ─────────────────────────────────────────────────────────────────────────────
// Payments
// ─────────────────────────────────────────────────────────────────────────────

final paymentRemoteDatasourceProvider = Provider<IPaymentRemoteDatasource>(
    (ref) => PaymentRemoteDatasource(ref.watch(apiClientProvider)));

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) =>
    PaymentRepositoryImpl(ref.watch(paymentRemoteDatasourceProvider)));

final savePaymentUseCaseProvider =
    Provider((ref) => SavePaymentUseCase(ref.watch(paymentRepositoryProvider)));
final deletePaymentUseCaseProvider =
    Provider((ref) => DeletePaymentUseCase(ref.watch(paymentRepositoryProvider)));
final fetchPaymentCommentsUseCaseProvider = Provider(
    (ref) => FetchPaymentCommentsUseCase(ref.watch(paymentRepositoryProvider)));
final postPaymentCommentUseCaseProvider = Provider(
    (ref) => PostPaymentCommentUseCase(ref.watch(paymentRepositoryProvider)));
final deletePaymentCommentUseCaseProvider = Provider(
    (ref) => DeletePaymentCommentUseCase(ref.watch(paymentRepositoryProvider)));

// ─────────────────────────────────────────────────────────────────────────────
// Activity
// ─────────────────────────────────────────────────────────────────────────────

final activityRemoteDatasourceProvider = Provider<IActivityRemoteDatasource>(
    (ref) => ActivityRemoteDatasource(ref.watch(apiClientProvider)));

final activityRepositoryProvider = Provider<IActivityRepository>((ref) =>
    ActivityRepositoryImpl(ref.watch(activityRemoteDatasourceProvider)));

final fetchActivityPageUseCaseProvider = Provider(
    (ref) => FetchActivityPageUseCase(ref.watch(activityRepositoryProvider)));
final markActivityReadUseCaseProvider = Provider(
    (ref) => MarkActivityReadUseCase(ref.watch(activityRepositoryProvider)));

// ─────────────────────────────────────────────────────────────────────────────
// Friends
// ─────────────────────────────────────────────────────────────────────────────

final friendsRemoteDatasourceProvider = Provider<IFriendsRemoteDatasource>(
    (ref) => FriendsRemoteDatasource(ref.watch(apiClientProvider)));

final friendsRepositoryProvider = Provider<IFriendsRepository>((ref) =>
    FriendsRepositoryImpl(ref.watch(friendsRemoteDatasourceProvider)));

final fetchFriendsUseCaseProvider =
    Provider((ref) => FetchFriendsUseCase(ref.watch(friendsRepositoryProvider)));
