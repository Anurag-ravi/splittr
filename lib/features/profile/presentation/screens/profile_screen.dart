import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/current_user_provider.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/auth/presentation/screens/login_screen.dart';
import 'package:splittr/features/profile/presentation/controllers/profile_controller.dart';
import 'package:splittr/features/profile/presentation/providers/profile_providers.dart';
import 'package:splittr/features/profile/presentation/screens/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 150,
            width: w,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                  horizontal:
                      BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account',
                      style: TextStyle(
                          color: Colors.white, fontSize: 17)),
                  const SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset(
                              'assets/profile/${user.dp}.png'),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 17)),
                          Text(user.email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(user: user),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _optionTile(
              icon: Icons.qr_code,
              title: 'Scan Code',
              opacity: 0.2),
          _sectionTitle('Preferences'),
          _optionTile(
              icon: Icons.email_outlined,
              title: 'Email settings',
              opacity: 0.2),
          _optionTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications settings',
              opacity: 0.2),
          _optionTile(
              icon: Icons.lock_outline_rounded,
              title: 'Passcode',
              opacity: 0.2),
          _sectionTitle('Feedback'),
          _optionTile(
            icon: Icons.star_outlined,
            title: 'Rate us',
            onTap: () => _showFeedbackDialog(context, notifier,
              user.name,
              title: 'Rate us',
              subtitle: 'Give us some feedback',
              type: 'feedback',
              showRating: true,
            ),
          ),
          _optionTile(
            icon: Icons.bug_report_outlined,
            title: 'Bug/Feature Request',
            onTap: () => _showFeedbackDialog(context, notifier,
              user.name,
              title: 'Bug/Feature Request',
              subtitle:
                  'Please describe the bug or feature request',
              type: 'bug/feature',
            ),
          ),
          _optionTile(
            icon: Icons.question_mark_outlined,
            title: 'Support',
            onTap: () => _showFeedbackDialog(context, notifier,
              user.name,
              title: 'Support Request',
              subtitle:
                  'Please describe the problem you are facing',
              type: 'support',
            ),
          ),
          Container(
            height: 50,
            width: w,
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5))),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () async {
                  Haptics.medium();
                  await notifier.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.primary, size: 30),
                    SizedBox(width: 20),
                    Text('Log out',
                        style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Made with ❤️ by Anurag',
                style:
                    TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Build number: ${const String.fromEnvironment('TAG')}',
              style:
                  const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDialog(
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

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRating) ...[
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (v) => rating = v,
              ),
              const SizedBox(height: 10),
            ],
            Text(subtitle, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            TextField(
              maxLines: showRating ? 1 : 3,
              onChanged: (v) => feedback = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit')),
        ],
      ),
    );

    if (res != true || !context.mounted) return;
    final body = showRating ? 'Rating: $rating, $feedback' : feedback;
    await notifier.submitFeedback(
      message: body,
      userName: userName,
      category: type,
    );
  }

  static Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(title,
            style:
                const TextStyle(color: Colors.white, fontSize: 12)),
      );

  static Widget _optionTile({
    required IconData icon,
    required String title,
    double opacity = 1,
    VoidCallback? onTap,
    Color color = Colors.white,
  }) =>
      Opacity(
        opacity: opacity,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 20),
                Text(title, style: TextStyle(color: color)),
              ],
            ),
          ),
        ),
      );
}
