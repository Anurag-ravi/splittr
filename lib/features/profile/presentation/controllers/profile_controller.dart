import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/features/profile/presentation/states/profile_state.dart';

class ProfileNotifier extends AsyncNotifier<ProfileSavedData?> {
  @override
  Future<ProfileSavedData?> build() async => null;

  Future<void> updateProfile({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(updateProfileUseCaseProvider).call(
          name: name,
          countryCode: countryCode,
          phone: phone,
          upiId: upiId,
        );
    if (result.isFailure) {
      state = AsyncError(result.failure.message, StackTrace.current);
      return;
    }
    final user = result.value;
    ref.read(currentUserProvider.notifier).state = user;
    state = AsyncData(ProfileSavedData(user));
  }

  Future<void> submitFeedback({
    required String message,
    required String userName,
    required String category,
  }) async {
    await AppHttpClient.postNoContext('/log', {
      'message': message,
      'user': userName,
      'category': category,
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await ref.read(logoutUseCaseProvider).call();
    if (result.isFailure) {
      state = AsyncError(result.failure.message, StackTrace.current);
      return;
    }
    ref.read(currentUserProvider.notifier).state = null;
    state = const AsyncData(null);
  }

  void reset() => state = const AsyncData(null);
}
