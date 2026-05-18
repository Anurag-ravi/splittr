// add_new_contact_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/utils/validators.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class AddNewContactScreen extends StatefulWidget {
  const AddNewContactScreen({
    super.key,
    required this.tripId,
    required this.trip,
  });

  final String tripId;

  final TripModel trip;

  @override
  State<AddNewContactScreen> createState() => _AddNewContactScreenState();
}

class _AddNewContactScreenState extends State<AddNewContactScreen> {
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  bool _nameValid = true;

  bool _emailValid = true;

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();

    _emailController.dispose();

    super.dispose();
  }

  Future<void> _addToTrip() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final nameOk = _nameController.text.trim().isNotEmpty;

    final emailOk = Validators.isValidEmail(
      _emailController.text.trim(),
    );

    setState(() {
      _nameValid = nameOk;

      _emailValid = emailOk;

      _loading = true;
    });

    if (!nameOk || !emailOk) {
      setState(() => _loading = false);

      return;
    }

    final data = await AppHttpClient.post(
      context,
      '/trip/${widget.tripId}/add-new',
      {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (data != null && data['status'] == 200) {
      final modified = List<TripMemberModel>.from(
        (data['data'] as List).map((x) => TripMemberModel.fromJson(x)),
      );

      final updated = widget.trip.copyWith(
        users: modified,
      );

      await HiveBoxes.trips.put(
        widget.trip.id,
        updated,
      );

      if (!mounted) return;

      Navigator.pop(context);

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data?['message']?.toString() ?? 'Error',
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required ThemeData theme,
    required bool valid,
    required String error,
  }) {
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      errorText: valid ? null : error,
      filled: true,
      fillColor: colorScheme.surface.withOpacity(0.88),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.primary.withOpacity(
            0.05,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.primary.withOpacity(
            0.05,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.primary,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Add Contact',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 14,
            ),
            child: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      Haptics.medium();

                      _addToTrip();
                    },
                    child: Center(
                      child: Text(
                        'Done',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 20,
                    sigmaY: 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: colorScheme.surface.withOpacity(0.90),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withOpacity(0.10),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 34,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _nameController,
                          cursorColor: colorScheme.primary,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (_) {
                            setState(() {
                              _nameValid = true;
                            });
                          },
                          decoration: _decoration(
                            label: 'Name',
                            theme: theme,
                            valid: _nameValid,
                            error: 'Name cannot be empty',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          cursorColor: colorScheme.primary,
                          keyboardType: TextInputType.emailAddress,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (_) {
                            setState(() {
                              _emailValid = true;
                            });
                          },
                          decoration: _decoration(
                            label: 'Email',
                            theme: theme,
                            valid: _emailValid,
                            error: 'Invalid email',
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: () {
                              Haptics.medium();

                              _addToTrip();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Add Contact',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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
