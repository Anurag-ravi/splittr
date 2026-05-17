import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/theme/app_radius.dart';
import 'package:splittr/features/auth/presentation/screens/login_screen.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  static const List<Map<String, String>> _pages = [
    {
      'title': 'Track Shared Expenses',
      'subtitle': 'Split bills with friends and groups easily.',
      'image': 'assets/onboarding/1.png',
    },
    {
      'title': 'Know Who Owes What',
      'subtitle': 'Real-time balances and settlements.',
      'image': 'assets/onboarding/2.png',
    },
    {
      'title': 'Manage Group Trips',
      'subtitle': 'Perfect for trips, roommates and outings.',
      'image': 'assets/onboarding/3.png',
    },
    {
      'title': 'Simple & Fast',
      'subtitle': 'Designed for effortless expense tracking.',
      'image': 'assets/onboarding/4.png',
    },
  ];

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);

    await prefs.setBool(
      AppConstants.prefKeyOnboardingDone,
      true,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // PAGE VIEW
            // =========================

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (v) {
                  setState(() {
                    _currentPage = v;
                  });
                },
                itemBuilder: (_, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.07,
                      vertical: h * 0.02,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // =========================
                        // IMAGE
                        // =========================

                        Expanded(
                          child: Center(
                            child: NeonGlow(
                              color: colorScheme.primary,
                              radius: w * 0.5,
                              spread: 24,
                              glowOpacity: 0.4,
                              child: Container(
                                width: w * 0.9,
                                // padding: EdgeInsets.all(w * 0.025),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.divider
                                        : AppColors.dividerLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.22)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Hero(
                                  tag: page['image']!,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      page['image']!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.04),

                        // =========================
                        // TITLE
                        // =========================

                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: h * 0.018),

                        // =========================
                        // SUBTITLE
                        // =========================

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.04,
                          ),
                          child: Text(
                            page['subtitle']!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // =========================
            // PAGE INDICATORS
            // =========================

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) {
                  final active = _currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.primary
                          : (isDark
                              ? AppColors.divider
                              : AppColors.dividerLight),
                      borderRadius: AppRadius.xlAll,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.35),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: h * 0.04),

            // =========================
            // BUTTON
            // =========================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.06,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: h * 0.04),
          ],
        ),
      ),
    );
  }
}
