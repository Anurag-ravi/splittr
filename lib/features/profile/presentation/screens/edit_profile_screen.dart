import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/features/profile/presentation/providers/profile_providers.dart';
import 'package:splittr/features/profile/presentation/states/profile_state.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.user});

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
    _nameController = TextEditingController(text: widget.user.name);
    _upiController = TextEditingController(text: widget.user.upiId);
    _countryCode = widget.user.countryCode;
    _number = widget.user.phone;
    ref.listenManual<AsyncValue<ProfileSavedData?>>(profileNotifierProvider,
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
          if (result == null) return;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 3)));
            _showSnack('Profile updated');
          });
          controller.reset();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final controller = ref.read(profileNotifierProvider.notifier);
    final loading = profileAsync.isLoading;

    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
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
                initialValue: widget.user.countryCode + widget.user.phone,
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
                      controller.updateProfile(
                        name: _nameController.text,
                        countryCode: _countryCode,
                        phone: _number,
                        upiId: _upiController.text,
                      );
                    },
              child: Container(
                width: w * 0.90,
                height: w * 0.14,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
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
