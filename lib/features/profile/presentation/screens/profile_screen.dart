// COMPLETE profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/providers/theme_provider.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/auth/presentation/screens/login_screen.dart';
import 'package:splittr/features/profile/presentation/controllers/profile_controller.dart';
import 'package:splittr/features/profile/presentation/providers/profile_providers.dart';
import 'package:splittr/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final user = ref.watch(currentUserProvider);

    final notifier = ref.read(profileNotifierProvider.notifier);

    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        110,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonGlow(
            color: colorScheme.primary,
            radius: 24,
            spread: -8,
            glowOpacity: 0.08,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(
                  theme.brightness == Brightness.dark ? 0.92 : 0.98,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.16 : 0.04,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: ProfileImage(
                          id: user.name,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      user: user,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle(
            context,
            'Preferences',
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: switch (themeMode) {
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
              _ => 'System',
            },
            onTap: () => _showThemeSheet(
              context,
              ref,
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle(
            context,
            'Feedback',
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.star_rounded,
            title: 'Rate us',
            onTap: () => _showFeedbackDialog(
              context,
              notifier,
              user.name,
              title: 'Rate us',
              subtitle: 'Give us some feedback',
              type: 'feedback',
              showRating: true,
            ),
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.bug_report_rounded,
            title: 'Bug / Feature Request',
            onTap: () => _showFeedbackDialog(
              context,
              notifier,
              user.name,
              title: 'Bug / Feature Request',
              subtitle: 'Describe the bug or feature request',
              type: 'bug/feature',
            ),
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.support_agent_rounded,
            title: 'Support',
            onTap: () => _showFeedbackDialog(
              context,
              notifier,
              user.name,
              title: 'Support Request',
              subtitle: 'Describe the problem you are facing',
              type: 'support',
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () async {
              Haptics.medium();

              await notifier.logout();

              if (!context.mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(
                  theme.brightness == Brightness.dark ? 0.12 : 0.08,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.error.withOpacity(
                    0.12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Log out',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: Text(
              'Made with ❤️ by Anurag',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.68),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Build ${const String.fromEnvironment('TAG')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static Future<void> _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final theme = Theme.of(context);

    final current = ref.read(themeModeProvider);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeTile(
                title: 'System',
                selected: current == ThemeMode.system,
                onTap: () {
                  ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system);

                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _ThemeTile(
                title: 'Light',
                selected: current == ThemeMode.light,
                onTap: () {
                  ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light);

                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _ThemeTile(
                title: 'Dark',
                selected: current == ThemeMode.dark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showFeedbackDialog(
    BuildContext context,
    ProfileNotifier notifier,
    String userName, {
    required String title,
    required String subtitle,
    required String type,
    bool showRating = false,
  }) async {
    Haptics.medium();

    double rating = 5;

    String feedback = '';

    final theme = Theme.of(context);

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRating) ...[
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (_, __) => Icon(
                  Icons.star_rounded,
                  color: theme.colorScheme.primary,
                ),
                onRatingUpdate: (v) => rating = v,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: showRating ? 1 : 4,
              onChanged: (v) => feedback = v,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (res != true || !context.mounted) {
      return;
    }

    final body = showRating ? 'Rating: $rating, $feedback' : feedback;

    await notifier.submitFeedback(
      message: body,
      userName: userName,
      category: type,
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(
            theme.brightness == Brightness.dark ? 0.92 : 0.98,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withOpacity(
              0.08,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withOpacity(0.10)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : theme.dividerTheme.color ?? Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
