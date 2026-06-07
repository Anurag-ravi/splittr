import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/auth/presentation/controllers/auth_controller.dart';
import 'package:splittr/features/auth/presentation/states/auth_state.dart';

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthResult?>(AuthNotifier.new);
