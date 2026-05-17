import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/features/auth/presentation/providers/auth_providers.dart';
import 'package:splittr/features/auth/presentation/screens/complete_signup_screen.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.hash, required this.email});

  final String hash;
  final String email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ));

  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<AuthResult?>>(authNotifierProvider, (_, next) {
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
          if (result == null) return;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            switch (result) {
              case AuthNewUserResult(:final email):
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => CompleteSignUpScreen(email: email)));
              case AuthExistingUserResult():
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 0)));
              default:
                break;
            }
          });
          notifier.reset();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
    final loading = authAsync.isLoading;

    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: w * 0.2),
            SvgPicture.asset('assets/images/logo.svg', height: w * 0.35),
            SizedBox(height: w * 0.1),
            Text(
              'OTP sent to ${widget.email}',
              style: TextStyle(
                fontSize: w * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(w * 0.05),
              child: TextField(
                controller: _otpController,
                cursorColor: Colors.grey[900],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  labelText: 'OTP',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            SizedBox(height: w * 0.02),
            GestureDetector(
              onTap: loading
                  ? null
                  : () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      notifier.verifyOtp(
                        email: widget.email,
                        otp: _otpController.text,
                        hash: widget.hash,
                      );
                    },
              child: Container(
                width: w * 0.90,
                height: w * 0.14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          height: w * 0.08,
                          width: w * 0.08,
                          child: const CircularProgressIndicator(
                              color: Colors.white),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
