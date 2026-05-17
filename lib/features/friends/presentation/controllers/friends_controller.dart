import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';

class FriendsNotifier extends AsyncNotifier<List<FriendEntity>> {
  @override
  Future<List<FriendEntity>> build() async {
    // Seed with cached data synchronously
    return ref.read(friendsRepositoryProvider).getCachedFriends();
  }

  Future<void> initialize() async {
    // Show cached immediately (already in state from build())
    final prefs = ref.read(sharedPreferencesProvider);
    final cachedNumbers = _readNumbers(prefs);

    if (cachedNumbers.isNotEmpty) {
      await _sync(cachedNumbers);
    }

    final granted = await _requestPermission();
    if (!granted) return;

    final latest = await _readContacts();
    if (!_sameSet(cachedNumbers, latest)) {
      await prefs.setString(
          AppConstants.prefKeyNumbers, jsonEncode(latest));
      await _sync(latest);
    }
  }

  Future<void> _sync(List<String> numbers) async {
    final result =
        await ref.read(fetchFriendsUseCaseProvider).call(numbers);
    result.when(
      success: (friends) => state = AsyncData(friends),
      onFailure: (_) {}, // Keep cached data on network failure
    );
  }

  List<String> _readNumbers(dynamic prefs) {
    try {
      final raw = prefs.getString(AppConstants.prefKeyNumbers) as String?;
      if (raw == null) return [];
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) return true;
    status = await Permission.contacts.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    return status.isGranted;
  }

  Future<List<String>> _readContacts() async {
    final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone});
    final numbers = <String>{};
    for (final c in contacts) {
      for (final p in c.phones) {
        String num = p.number.replaceAll(RegExp(r'\s+|-|\(|\)'), '');
        if (num.length > 10) num = num.substring(num.length - 10);
        if (num.length == 10) numbers.add(num);
      }
    }
    return numbers.toList();
  }

  bool _sameSet(List<String> a, List<String> b) =>
      a.toSet().length == b.toSet().length &&
      a.toSet().containsAll(b.toSet());
}
