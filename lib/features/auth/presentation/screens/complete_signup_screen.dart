import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/auth/presentation/providers/auth_providers.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';

class CompleteSignUpScreen extends ConsumerStatefulWidget {
  const CompleteSignUpScreen({super.key, required this.email});

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

  bool _isValidUpiId(String id) =>
      RegExp(r'^[a-z0-9.\-]{2,256}@[a-z]{2,64}$').hasMatch(id);

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
          if (result is! AuthExistingUserResult) return;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 0)));
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
              'Complete the Signup',
              style: TextStyle(
                fontSize: w * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: w * 0.03),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: w * 0.04,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: w * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: TextField(
                controller: _nameController,
                cursorColor: Colors.grey[900],
                onChanged: (_) => setState(() => _nameValid = true),
                decoration: _nameValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                        ),
                        labelText: 'Name',
                        fillColor: Colors.white,
                        filled: true,
                      )
                    : const InputDecoration(
                        errorText: 'Please enter a valid name'),
              ),
            ),
            SizedBox(height: w * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: IntlPhoneField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  labelText: 'Mobile',
                  fillColor: Colors.white,
                  filled: true,
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  setState(() {
                    _countryCode = phone.countryCode;
                    _number = phone.number;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: TextField(
                controller: _upiController,
                cursorColor: Colors.grey[900],
                onChanged: (_) => setState(() => _upiValid = true),
                decoration: _upiValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                        ),
                        labelText: 'UPI ID',
                        fillColor: Colors.white,
                        filled: true,
                      )
                    : const InputDecoration(
                        errorText: 'Please enter a valid UPI ID'),
              ),
            ),
            SizedBox(height: w * 0.05),
            GestureDetector(
              onTap: loading
                  ? null
                  : () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Haptics.medium();
                      final nameOk = _nameController.text.isNotEmpty;
                      final upiOk = _isValidUpiId(_upiController.text);
                      setState(() {
                        _nameValid = nameOk;
                        _upiValid = upiOk;
                      });
                      if (!nameOk || !upiOk) return;
                      notifier.register(
                        name: _nameController.text,
                        countryCode: _countryCode,
                        phone: _number,
                        upiId: _upiController.text,
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
                          'Submit',
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
