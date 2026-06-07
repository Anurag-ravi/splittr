import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/auth/presentation/providers/auth_providers.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class CompleteSignUpScreen extends ConsumerStatefulWidget {
  const CompleteSignUpScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<CompleteSignUpScreen> createState() =>
      _CompleteSignUpScreenState();
}

class _CompleteSignUpScreenState extends ConsumerState<CompleteSignUpScreen> {
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();

  bool _nameValid = true;
  bool _upiValid = true;

  String _countryCode = '';
  String _number = '';

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  bool _isValidUpiId(String id) => RegExp(
        r'^[a-z0-9.\-]{2,256}@[a-z]{2,64}$',
      ).hasMatch(id);

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

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

              _showSnack(e.toString());
            });

            notifier.reset();
          },
          data: (result) {
            if (result is! AuthExistingUserResult) {
              return;
            }

            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(
                    initialIndex: 0,
                  ),
                ),
              );
            });

            notifier.reset();
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);

    final notifier = ref.read(authNotifierProvider.notifier);

    final loading = authAsync.isLoading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final w = MediaQuery.of(context).size.width;

    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.06,
          ),
          child: Column(
            children: [
              SizedBox(height: h * 0.05),

              // =========================
              // LOGO
              // =========================

              NeonGlow(
                color: colorScheme.primary,
                radius: w * 0.18,
                spread: 24,
                glowOpacity: 0.18,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: w * 0.28,
                ),
              ),

              SizedBox(height: h * 0.04),

              // =========================
              // TITLE
              // =========================

              Text(
                'Complete Your Signup',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),

              SizedBox(height: h * 0.015),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),

              SizedBox(height: h * 0.06),

              // =========================
              // NAME
              // =========================

              TextField(
                controller: _nameController,
                cursorColor: colorScheme.primary,
                onChanged: (_) {
                  setState(() {
                    _nameValid = true;
                  });
                },
                style: theme.textTheme.bodyLarge,
                decoration: _inputDecoration(
                  context: context,
                  label: 'Name',
                  errorText: _nameValid ? null : 'Please enter a valid name',
                ),
              ),

              SizedBox(height: h * 0.025),

              // =========================
              // PHONE
              // =========================

              IntlPhoneField(
                initialCountryCode: 'IN',
                cursorColor: colorScheme.primary,
                dropdownIcon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurface,
                ),
                style: theme.textTheme.bodyLarge,
                decoration: _inputDecoration(
                  context: context,
                  label: 'Mobile',
                ),
                onChanged: (phone) {
                  setState(() {
                    _countryCode = phone.countryCode;

                    _number = phone.number;
                  });
                },
              ),

              SizedBox(height: h * 0.01),

              // =========================
              // UPI
              // =========================

              TextField(
                controller: _upiController,
                cursorColor: colorScheme.primary,
                onChanged: (_) {
                  setState(() {
                    _upiValid = true;
                  });
                },
                style: theme.textTheme.bodyLarge,
                decoration: _inputDecoration(
                  context: context,
                  label: 'UPI ID',
                  errorText: _upiValid ? null : 'Please enter a valid UPI ID',
                ),
              ),

              SizedBox(height: h * 0.05),

              // =========================
              // BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();

                          Haptics.medium();

                          final nameOk = _nameController.text.isNotEmpty;

                          final upiOk = _isValidUpiId(
                            _upiController.text,
                          );

                          setState(() {
                            _nameValid = nameOk;

                            _upiValid = upiOk;
                          });

                          if (!nameOk || !upiOk) {
                            return;
                          }

                          notifier.register(
                            name: _nameController.text,
                            countryCode: _countryCode,
                            phone: _number,
                            upiId: _upiController.text,
                          );
                        },
                  child: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
