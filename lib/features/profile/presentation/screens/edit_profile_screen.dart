// COMPLETE edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/features/profile/presentation/providers/profile_providers.dart';
import 'package:splittr/features/profile/presentation/states/profile_state.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;

  late final TextEditingController _upiController;

  bool _nameValid = true;

  bool _upiValid = true;

  String _countryCode = '';

  String _number = '';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.user.name,
    );

    _upiController = TextEditingController(
      text: widget.user.upiId,
    );

    _countryCode = widget.user.countryCode;

    _number = widget.user.phone;

    ref.listenManual<AsyncValue<ProfileSavedData?>>(
      profileNotifierProvider,
      (_, next) {
        final controller = ref.read(profileNotifierProvider.notifier);

        next.whenOrNull(
          error: (e, _) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _showSnack(e.toString());
            });

            controller.reset();
          },
          data: (result) {
            if (result == null || !mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(initialIndex: 3),
                ),
              );

              _showSnack('Profile updated');
            });

            controller.reset();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();

    _upiController.dispose();

    super.dispose();
  }

  bool _isValidUpiId(String id) {
    return RegExp(
      r'^[a-z0-9.\-]{2,256}@[a-z]{2,64}$',
    ).hasMatch(id);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final profileAsync = ref.watch(profileNotifierProvider);

    final controller = ref.read(profileNotifierProvider.notifier);

    final loading = profileAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          40,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            NeonGlow(
              color: colorScheme.primary,
              radius: 26,
              spread: -10,
              glowOpacity: 0.10,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(
                    theme.brightness == Brightness.dark ? 0.92 : 0.98,
                  ),
                  borderRadius: BorderRadius.circular(34),
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
                child: Column(
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: ProfileImage(
                            id: widget.user.name,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Label(
                      text: 'Name',
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: _nameController,
                      hint: 'Enter your name',
                      error: !_nameValid ? 'Please enter valid name' : null,
                      onChanged: (_) {
                        setState(() {
                          _nameValid = true;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    _Label(
                      text: 'Mobile',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.08),
                        ),
                      ),
                      child: IntlPhoneField(
                        initialValue:
                            widget.user.countryCode + widget.user.phone,
                        initialCountryCode: 'IN',
                        dropdownIconPosition: IconPosition.trailing,
                        disableLengthCheck: true,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.42),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        onChanged: (phone) {
                          _countryCode = phone.countryCode;

                          _number = phone.number;
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    _Label(
                      text: 'UPI ID',
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: _upiController,
                      hint: 'example@upi',
                      error: !_upiValid ? 'Please enter valid UPI ID' : null,
                      onChanged: (_) {
                        setState(() {
                          _upiValid = true;
                        });
                      },
                    ),
                    const SizedBox(height: 34),
                    NeonGlow(
                      color: colorScheme.primary,
                      radius: 24,
                      spread: -4,
                      glowOpacity: 0.22,
                      child: GestureDetector(
                        onTap: loading
                            ? null
                            : () {
                                FocusManager.instance.primaryFocus?.unfocus();

                                Haptics.medium();

                                final nameOk =
                                    _nameController.text.trim().isNotEmpty;

                                final upiOk = _isValidUpiId(
                                  _upiController.text.trim(),
                                );

                                setState(() {
                                  _nameValid = nameOk;

                                  _upiValid = upiOk;
                                });

                                if (!nameOk || !upiOk) {
                                  return;
                                }

                                controller.updateProfile(
                                  name: _nameController.text.trim(),
                                  countryCode: _countryCode,
                                  phone: _number,
                                  upiId: _upiController.text.trim(),
                                );
                              },
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              24,
                            ),
                          ),
                          child: Center(
                            child: loading
                                ? SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.72),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.error,
    this.onChanged,
  });

  final TextEditingController controller;

  final String hint;

  final String? error;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: error != null
                  ? colorScheme.error
                  : colorScheme.primary.withOpacity(0.08),
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.42),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
