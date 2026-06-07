import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/core/theme/app_radius.dart';
import 'package:splittr/core/widgets/profile_image.dart';
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
      'subtitle': 'Split bills with friends and groups beautifully.',
    },
    {
      'title': 'Know Who Owes What',
      'subtitle': 'Real-time balances and instant settlements.',
    },
    {
      'title': 'Powerful Insights',
      'subtitle': 'See spending trends and group analytics.',
    },
    {
      'title': 'Split Smarter',
      'subtitle': 'Fast, modern and built for group travel.',
    },
  ];

  Future<void> _finish() async {
    final prefs = ref.read(
      sharedPreferencesProvider,
    );

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
        duration: const Duration(
          milliseconds: 350,
        ),
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

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: NeonGlow(
                            width: w * 0.95,
                            height: h * 0.6,
                            color: colorScheme.primary,
                            radius: 40,
                            spread: 25,
                            glowOpacity: isDark ? 0.14 : 0.08,
                            child: Container(
                              width: w * 0.95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(38),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isDark
                                      ? [
                                          const Color(0xFF0B1020),
                                          theme.scaffoldBackgroundColor,
                                        ]
                                      : [
                                          Colors.white,
                                          const Color(0xFFF3F6FB),
                                        ],
                                ),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(
                                    isDark ? 0.08 : 0.06,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.22)
                                        : Colors.black.withOpacity(0.06),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(38),
                                child: SizedBox(
                                  height: h * 0.6,
                                  child: _onboardingPreview(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      Text(
                        page['title']!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: h * 0.016),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.06,
                        ),
                        child: Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.72),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) {
                  final active = _currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.primary
                          : theme.dividerTheme.color ?? Colors.grey,
                      borderRadius: AppRadius.xlAll,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 14,
                              ),
                            ]
                          : [],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: h * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
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

  Widget _onboardingPreview(int index) {
    switch (index) {
      case 0:
        return _groupsPreview();

      case 1:
        return _settlementPreview();

      case 2:
        return _analyticsPreview();

      default:
        return _networkPreview();
    }
  }

  Widget _groupsPreview() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: -(h / 10),
          right: -w / 10,
          child: _glowBall(),
        ),
        Positioned(
          bottom: -h / 10,
          left: -w / 10,
          child: _glowBall(),
        ),
        Padding(
          padding: EdgeInsets.all(w / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Splittr',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: h / 60),
              _glassCard(
                child: Row(
                  children: [
                    Container(
                      width: h / 12,
                      height: h / 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.22),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.06),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.beach_access_rounded,
                        size: h / 25,
                      ),
                    ),
                    SizedBox(width: w / 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goa Trip',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: h / 100),
                          Text(
                            'You are owed ₹2,430',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h / 50),
              Transform.rotate(
                angle: -.06,
                child: _floatingExpenseCard(
                  title: 'Dinner at Thallasa',
                  amount: '₹1,240',
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: h / 60),
              Transform.translate(
                offset: Offset(w / 11, 0),
                child: _floatingExpenseCard(
                  title: 'Uber',
                  amount: '₹430',
                  color: Colors.cyan,
                ),
              ),
              const Spacer(),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent balances',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: h / 70),
                    _balanceRow('Anurag', '+₹540', true),
                    SizedBox(height: h / 70),
                    _balanceRow('Pragya', '-₹220', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settlementPreview() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final transforms = [
      (
        angle: -0.08,
        offset: Offset(-(h / 90), 0),
      ),
      (
        angle: 0.05,
        offset: Offset(h / 50, 0),
      ),
      (
        angle: -0.04,
        offset: Offset(h / 100, 0),
      ),
      (
        angle: 0.09,
        offset: Offset(-(h / 90), 0),
      ),
    ];

    final people = [
      ('Anurag', '₹350', true),
      ('Pragya', '₹220', false),
      ('Akshay', '₹240', false),
      ('Kalhapure', '₹310', true),
    ];

    return Stack(
      children: [
        Positioned(
          top: -(h / 10),
          right: -w / 10,
          child: _glowBall(),
        ),
        Positioned(
          bottom: -h / 10,
          left: -w / 10,
          child: _glowBall(),
        ),
        Padding(
          padding: EdgeInsets.all(h / 50),
          child: Column(
            children: [
              ...List.generate(
                people.length,
                (i) {
                  final t = transforms[i];

                  return Padding(
                    padding: EdgeInsets.only(bottom: h / 50),
                    child: Transform.translate(
                      offset: t.offset,
                      child: Transform.rotate(
                        angle: t.angle,
                        child: _settleCard(
                          people[i].$1,
                          people[i].$2,
                          people[i].$3,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              _glassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '₹12,420',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: h / 40,
                            ),
                          ),
                          SizedBox(height: h / 100),
                          const Text('Total Settled'),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 54,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black12,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Instant',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: h / 40,
                            ),
                          ),
                          SizedBox(height: h / 100),
                          Text('Settlement'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analyticsPreview() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: -(h / 10),
          right: -w / 10,
          child: _glowBall(),
        ),
        Positioned(
          bottom: -h / 10,
          left: -w / 10,
          child: _glowBall(),
        ),
        Padding(
          padding: EdgeInsets.all(h / 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h / 50),
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: h / 55),
              _glassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: h / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.donut_large_rounded,
                                size: h / 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: h / 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Legend(label: 'Food'),
                            SizedBox(height: h / 65),
                            _Legend(label: 'Travel'),
                            SizedBox(height: h / 65),
                            _Legend(label: 'Hotel'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: h / 50),
              Expanded(
                child: Column(
                  children: [
                    _analyticsRow('Dinner', '₹820'),
                    SizedBox(height: h / 60),
                    _analyticsRow('Cab', '₹240'),
                    SizedBox(height: h / 60),
                    _analyticsRow('Hotel', '₹4,240'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _networkPreview() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -(h / 10),
          right: -w / 10,
          child: _glowBall(),
        ),
        Positioned(
          bottom: -h / 10,
          left: -w / 10,
          child: _glowBall(),
        ),
        CustomPaint(
          size: Size(w, h),
          painter: _NetworkLinesPainter(
            centerX: (w * 0.95) / 2,
            centerY: h * 0.3,
            radiusX: w * 0.4,
            radiusY: h * 0.25,
            context: context,
          ),
        ),
        ...List.generate(
          8,
          (i) {
            final angle = (i * 45) * pi / 180;

            final randChar = String.fromCharCode(
              65 + Random().nextInt(26),
            );

            // center of preview area
            final centerX = (w * 0.95) / 2;
            final centerY = h * 0.3;

            // responsive orbit radius
            final radiusX = w * 0.4;
            final radiusY = h * 0.25;

            // profile size compensation
            const avatarSize = 54.0;

            return Positioned(
              left: centerX + radiusX * cos(angle) - (avatarSize / 2),
              top: centerY + radiusY * sin(angle) - (avatarSize / 2),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: ProfileImage(
                  id: randChar,
                ),
              ),
            );
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeonGlow(
              color: Theme.of(context).colorScheme.primary,
              radius: 50,
              spread: 8,
              glowOpacity:
                  Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.12,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.28
                                  : 0.16,
                            ),
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                      ],
                    ),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Icon(Icons.shield_rounded,
                      size: 72, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            SizedBox(height: h / 40),
            Text(
              'Splittr',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: h / 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _featurePill('Secure Splits'),
                _featurePill('Group Insights'),
                _featurePill('Fast Settles'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Container(
          padding: EdgeInsets.all(h / 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.72),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _floatingExpenseCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return _glassCard(
      child: Row(
        children: [
          Container(
            width: h / 20,
            height: h / 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(0.18),
            ),
            child: Icon(
              Icons.receipt,
              color: color,
            ),
          ),
          SizedBox(width: w / 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: h / 120),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settleCard(
    String name,
    String amount,
    bool positive,
  ) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return _glassCard(
      child: Row(
        children: [
          SizedBox(
            width: h / 20,
            height: h / 20,
            child: ProfileImage(id: name),
          ),
          SizedBox(width: w / 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: h / 120),
                Text(
                  '$amount in total',
                  style: TextStyle(
                    color: positive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Settle'),
          ),
        ],
      ),
    );
  }

  Widget _analyticsRow(
    String title,
    String amount,
  ) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return _glassCard(
      child: Row(
        children: [
          Container(
            width: h / 20,
            height: h / 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: w / 30),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(
    String name,
    String amount,
    bool positive,
  ) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Row(
      children: [
        SizedBox(
          width: h / 20,
          height: h / 20,
          child: ProfileImage(id: name),
        ),
        SizedBox(width: w / 30),
        Expanded(
          child: Text(name),
        ),
        Text(
          amount,
          style: TextStyle(
            color: positive
                ? Theme.of(context).colorScheme.primary
                : Colors.orange,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _featurePill(
    String text,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _glowBall() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(
                  isDark ? 0.18 : 0.10,
                ),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _NetworkLinesPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;
  final BuildContext context;

  _NetworkLinesPainter({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = List.generate(
      8,
      (i) {
        final angle = (i * 45) * pi / 180;

        return Offset(
          centerX + radiusX * cos(angle),
          centerY + radiusY * sin(angle),
        );
      },
    );

    final paint = Paint()
      ..color = Theme.of(context).colorScheme.primary.withOpacity(0.2)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // simulated random-ish connections
    final connections = [
      [0, 2],
      [0, 5],
      [1, 3],
      [1, 6],
      [2, 4],
      [3, 7],
      [4, 6],
      [5, 7],
      [0, 7],
    ];

    for (final c in connections) {
      final path = Path()
        ..moveTo(points[c[0]].dx, points[c[0]].dy)
        ..quadraticBezierTo(
          (points[c[0]].dx + points[c[1]].dx) / 2,
          (points[c[0]].dy + points[c[1]].dy) / 2 - 40,
          points[c[1]].dx,
          points[c[1]].dy,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
