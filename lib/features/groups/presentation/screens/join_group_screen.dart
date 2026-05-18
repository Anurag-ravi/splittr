import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/features/groups/presentation/states/groups_state.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _codeController = TextEditingController();

  bool _codeValid = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

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

    ref.listenManual<AsyncValue<GroupMutationSuccess?>>(
      groupMutationProvider,
      (_, next) {
        final notifier = ref.read(groupMutationProvider.notifier);

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
            if (result == null) return;

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

              _showSnack(result.message);
            });

            notifier.reset();
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: 'Group Code',
      hintText: 'Enter invite code',
      errorText: _codeValid ? null : 'Please enter a valid code',
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),
      labelStyle: theme.textTheme.bodyLarge?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final mutAsync = ref.watch(groupMutationProvider);

    final notifier = ref.read(groupMutationProvider.notifier);

    final loading = mutAsync.isLoading;

    final w = MediaQuery.of(context).size.width;

    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            Haptics.medium();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Join Group',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
                spread: 22,
                glowOpacity: 0.18,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: w * 0.16,
                  ),
                ),
              ),

              SizedBox(height: h * 0.05),

              // =========================
              // TITLE
              // =========================

              Text(
                'Join Existing Group',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: h * 0.015),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.08,
                ),
                child: Text(
                  'Enter the invite code shared by your friends to instantly join the group.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),

              SizedBox(height: h * 0.06),

              // =========================
              // INPUT
              // =========================

              TextField(
                controller: _codeController,
                cursorColor: colorScheme.primary,
                style: theme.textTheme.bodyLarge,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) {
                  setState(() {
                    _codeValid = true;
                  });
                },
                decoration: _inputDecoration(
                  context,
                ),
              ),

              SizedBox(height: h * 0.04),

              // =========================
              // JOIN BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          Haptics.medium();

                          FocusManager.instance.primaryFocus?.unfocus();

                          final ok = _codeController.text.trim().length == 10;

                          setState(() {
                            _codeValid = ok;
                          });

                          if (!ok) return;

                          notifier.joinGroup(
                            _codeController.text.trim(),
                          );
                        },
                  child: loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          'Join Group',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
