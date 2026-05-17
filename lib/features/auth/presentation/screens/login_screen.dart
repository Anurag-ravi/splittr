import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/features/auth/presentation/providers/auth_providers.dart';
import 'package:splittr/features/auth/presentation/screens/complete_signup_screen.dart';
import 'package:splittr/features/auth/presentation/screens/otp_screen.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<AuthResult?>>(
      authNotifierProvider,
      (_, next) {
        final notifier = ref.read(authNotifierProvider.notifier);

        next.whenOrNull(
          error: (e, _) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  duration: const Duration(seconds: 4),
                ),
              );
            });

            notifier.reset();
          },
          data: (result) {
            if (result == null || !mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              switch (result) {
                case AuthOtpSentResult(:final email, :final hash):
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OtpScreen(
                        email: email,
                        hash: hash,
                      ),
                    ),
                  );

                case AuthNewUserResult(:final email):
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => CompleteSignUpScreen(email: email),
                    ),
                  );

                case AuthExistingUserResult():
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 0),
                    ),
                  );

                default:
                  break;
              }
            });

            notifier.reset();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final loading = authAsync.isLoading;

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: h * 0.15),

                // =========================
                // LOGO
                // =========================

                NeonGlow(
                  color: colorScheme.primary,
                  radius: w * 0.24,
                  spread: 28,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: w * 0.34,
                  ),
                ),

                SizedBox(height: h * 0.04),

                // =========================
                // TITLE
                // =========================

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.08,
                  ),
                  child: Text(
                    "Split expenses instantly\nwith friends & groups",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      letterSpacing: 0.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.015),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.12,
                  ),
                  child: Text(
                    "Track group expenses and settle instantly.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.07),

                // =========================
                // GOOGLE BUTTON
                // =========================

                GestureDetector(
                  onTap: () => notifier.googleSignIn(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: w * 0.82,
                    height: w * 0.17,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.05,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.divider
                            : AppColors.dividerLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.22)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // GOOGLE ICON

                        Container(
                          padding: EdgeInsets.all(w * 0.018),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.18),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/google.svg',
                            height: w * 0.055,
                          ),
                        ),

                        SizedBox(width: w * 0.04),

                        // BUTTON TEXT

                        Text(
                          'Continue with Google',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: h * 0.035,
                  ),
                  child: Text(
                    'Powered by Splittr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.textMuted
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
