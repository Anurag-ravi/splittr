import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';

/// Holds the currently logged-in user as a domain [UserEntity].
/// Updated after login / register / profile edit / logout.
final currentUserProvider = StateProvider<UserEntity?>((ref) {
  final legacy = HiveBoxes.me.get(AppConstants.hiveBoxMe);
  if (legacy == null) return null;
  return UserEntity(
    id: legacy.id,
    name: legacy.name,
    email: legacy.email,
    countryCode: legacy.countryCode,
    phone: legacy.phone,
    upiId: legacy.upiId,
    dp: legacy.dp,
  );
});
