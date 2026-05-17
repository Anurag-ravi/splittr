import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';

class AuthNotifier extends AsyncNotifier<AuthResult?> {
  @override
  Future<AuthResult?> build() async => null;

  // ── OTP ──────────────────────────────────────────────────────────────────

  Future<void> sendOtp(String email) async {
    state = const AsyncLoading();
    final result = await ref.read(requestOtpUseCaseProvider).call(email);
    state = result.when(
      success: (hash) =>
          AsyncData(AuthOtpSentResult(email: email, hash: hash)),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String hash,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(verifyOtpUseCaseProvider)
        .call(email: email, otp: otp, hash: hash);
    state = result.when(
      success: (r) => AsyncData(
        r.isNewUser
            ? AuthNewUserResult(email: email)
            : AuthExistingUserResult(user: r.user),
      ),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
    if (state.hasValue && state.value is AuthExistingUserResult) {
      ref.read(currentUserProvider.notifier).state =
          (state.value as AuthExistingUserResult).user;
      await _fetchAllTrips();
    }
  }

  // ── Google OAuth ──────────────────────────────────────────────────────────

  Future<void> googleSignIn() async {
    state = const AsyncLoading();
    try {
      final UserCredential cred;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          state = const AsyncData(null);
          return;
        }
        final auth = await googleUser.authentication;
        cred = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          ),
        );
      }
      if (cred.user == null) {
        state = AsyncError('Error signing in with Google', StackTrace.current);
        return;
      }
      final token = await cred.user!.getIdToken();
      await _oauthLogin(token!);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }

  Future<void> _oauthLogin(String token) async {
    final result =
        await ref.read(oauthLoginUseCaseProvider).call(token);
    state = result.when(
      success: (r) => AsyncData(
        r.isNewUser
            ? AuthNewUserResult(email: r.user.email)
            : AuthExistingUserResult(user: r.user),
      ),
      onFailure: (f) => AsyncError(f.message, StackTrace.current),
    );
    if (state.hasValue && state.value is AuthExistingUserResult) {
      ref.read(currentUserProvider.notifier).state =
          (state.value as AuthExistingUserResult).user;
      await _fetchAllTrips();
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> register({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(registerUseCaseProvider).call(
          name: name,
          countryCode: countryCode,
          phone: phone,
          upiId: upiId,
        );
    if (result.isFailure) {
      final f = result.failure;
      state = AsyncError(f.message, StackTrace.current);
      return;
    }
    final user = result.value;
    ref.read(currentUserProvider.notifier).state = user;
    await _fetchAllTrips();
    state = AsyncData(AuthExistingUserResult(user: user));
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await ref.read(logoutUseCaseProvider).call();
    if (result.isFailure) {
      state = AsyncError(result.failure.message, StackTrace.current);
      return;
    }
    ref.read(currentUserProvider.notifier).state = null;
    state = const AsyncData(AuthLoggedOutResult());
  }

  void reset() => state = const AsyncData(null);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _fetchAllTrips() async {
    // Best-effort — failures are ignored; GroupScreen will retry on load.
    await ref.read(fetchAllTripsUseCaseProvider).call();
  }
}
