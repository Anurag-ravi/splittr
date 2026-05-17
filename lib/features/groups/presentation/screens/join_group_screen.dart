import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/groups/presentation/providers/groups_providers.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/features/groups/presentation/states/groups_state.dart';

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

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ));

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<GroupMutationSuccess?>>(groupMutationProvider,
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 0)));
            _showSnack(result.message);
          });
          notifier.reset();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutAsync = ref.watch(groupMutationProvider);
    final notifier = ref.read(groupMutationProvider.notifier);
    final loading = mutAsync.isLoading;

    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Join a group', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : GestureDetector(
                  onTap: () {
                    Haptics.medium();
                    FocusManager.instance.primaryFocus?.unfocus();
                    final ok = _codeController.text.length == 10;
                    setState(() => _codeValid = ok);
                    if (!ok) return;
                    notifier.joinGroup(_codeController.text);
                  },
                  child: const Text('Done',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
          const SizedBox(width: 5),
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
                controller: _codeController,
                onChanged: (_) => setState(() => _codeValid = true),
                decoration: _codeValid
                    ? InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(width: 1),
                        ),
                        labelText: 'Group Code',
                        fillColor: Colors.grey[900],
                        filled: true,
                      )
                    : const InputDecoration(
                        errorText: 'Please enter a valid code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
