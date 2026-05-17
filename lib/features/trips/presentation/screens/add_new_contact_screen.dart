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
  bool _nameValid = true, _emailValid = true, _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addToTrip() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final nameOk = _nameController.text.isNotEmpty;
    final emailOk = Validators.isValidEmail(_emailController.text);
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
      {'name': _nameController.text, 'email': _emailController.text},
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (data != null && data['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'].toString()),
        duration: const Duration(seconds: 4),
      ));
      final modified = List<TripMemberModel>.from(
          (data['data'] as List).map((x) => TripMemberModel.fromJson(x)));
      final updated = widget.trip.copyWith(users: modified);
      await HiveBoxes.trips.put(widget.trip.id, updated);
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data?['message']?.toString() ?? 'Error'),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Add a new contact',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Haptics.medium();
                _addToTrip();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: Text('Done',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: TextField(
                cursorColor: AppColors.primary,
                style: const TextStyle(color: Colors.white),
                controller: _nameController,
                onChanged: (_) => setState(() => _nameValid = true),
                decoration: _nameValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: 'Name',
                        fillColor: Colors.grey[900],
                        filled: true,
                      )
                    : const InputDecoration(errorText: 'Name cannot be empty'),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: TextField(
                cursorColor: AppColors.primary,
                style: const TextStyle(color: Colors.white),
                controller: _emailController,
                onChanged: (_) => setState(() => _emailValid = true),
                decoration: _emailValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: 'Email',
                        fillColor: Colors.grey[900],
                        filled: true,
                      )
                    : const InputDecoration(errorText: 'Invalid Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
