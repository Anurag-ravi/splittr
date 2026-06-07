import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/profile/presentation/controllers/profile_controller.dart';
import 'package:splittr/features/profile/presentation/states/profile_state.dart';

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileSavedData?>(
        ProfileNotifier.new);
