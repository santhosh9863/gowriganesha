import 'dart:math';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/user_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:crypto/crypto.dart';

String _detectPlatform() {
  if (kIsWeb) return 'web';
  try {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
  } catch (_) {}
  return 'unknown';
}

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override sharedPreferencesProvider in main.dart');
});

final roleProvider = StateNotifierProvider<RoleNotifier, UserRole>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RoleNotifier(prefs, ref);
});

final userNameProvider = StateProvider<String>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getString('userName') ?? '';
});

final userIdProvider = StateProvider<String>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getString('userId') ?? '';
});

class RoleNotifier extends StateNotifier<UserRole> {
  final SharedPreferences _prefs;
  final Ref _ref;

  RoleNotifier(this._prefs, this._ref) : super(UserRole.none) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final stored = _prefs.getString('role');
    if (stored != null) {
      state = UserRole.values.firstWhere(
        (r) => r.name == stored,
        orElse: () => UserRole.volunteer,
      );
    }
  }

  Future<void> setRole(UserRole role) async {
    state = role;
    await _prefs.setString('role', role.name);
  }

  Future<void> setUserName(String name) async {
    _ref.read(userNameProvider.notifier).state = name;
    await _prefs.setString('userName', name);
  }

  Future<void> setUserId(String id) async {
    _ref.read(userIdProvider.notifier).state = id;
    await _prefs.setString('userId', id);
  }

  String _ensureUserId() {
    final existing = _prefs.getString('userId');
    if (existing != null && existing.isNotEmpty) return existing;
    final newId = DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(999999).toString();
    _ref.read(userIdProvider.notifier).state = newId;
    _prefs.setString('userId', newId);
    return newId;
  }

  Future<void> setCredentials(UserRole role, String name) async {
    _ref.read(userNameProvider.notifier).state = name;
    await _prefs.setString('userName', name);
    state = role;
    await _prefs.setString('role', role.name);
  }

  Future<bool> loginAsAdmin(String password, {String? userName}) async {
    final service = _ref.read(firestoreProvider);
    final storedHash = await service.getAdminPasswordHash();
    _ensureUserId();
    if (storedHash == null) {
      await service.setAdminPasswordHash(_hashPassword(password));
      if (userName != null) await setUserName(userName);
      await setRole(UserRole.admin);
      await _registerUser(userName ?? '', UserRole.admin);
      return true;
    }
    if (storedHash == _hashPassword(password)) {
      if (userName != null) await setUserName(userName);
      await setRole(UserRole.admin);
      await _registerUser(userName ?? '', UserRole.admin);
      return true;
    }
    return false;
  }

  Future<bool> loginAsVolunteer(String password, {String? userName}) async {
    debugPrint('[VOLUNTEER_AUTH] Fetching password from Firestore');
    final service = _ref.read(firestoreProvider);
    final storedPassword = await service.getVolunteerPassword();
    debugPrint('[VOLUNTEER_AUTH] Firestore fetch complete: ${storedPassword != null ? "found" : "null"}');
    if (storedPassword == null) {
      debugPrint('[VOLUNTEER_AUTH] No volunteerPassword set — first login, saving password');
      await service.setVolunteerPassword(password);
      if (userName != null) await setUserName(userName);
      _ensureUserId();
      await setRole(UserRole.volunteer);
      await _registerUser(userName ?? '', UserRole.volunteer);
      debugPrint('[VOLUNTEER_AUTH] Role set to volunteer');
      return true;
    }
    if (password == storedPassword) {
      debugPrint('[VOLUNTEER_AUTH] Password match — granting access');
      if (userName != null) await setUserName(userName);
      _ensureUserId();
      await setRole(UserRole.volunteer);
      await _registerUser(userName ?? '', UserRole.volunteer);
      debugPrint('[VOLUNTEER_AUTH] Role set to volunteer');
      return true;
    }
    debugPrint('[VOLUNTEER_AUTH] Password mismatch — denying');
    return false;
  }

  Future<void> _registerUser(String name, UserRole role) async {
    final userId = _ref.read(userIdProvider);
    if (userId.isEmpty) return;
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (firebaseUid.isEmpty) return;

    final userService = _ref.read(userServiceProvider);
    final isNew = await userService.registerUser(
      userId: userId,
      name: name,
      role: role,
      firebaseUid: firebaseUid,
      device: _detectPlatform(),
    );

    if (isNew && role == UserRole.volunteer) {
      final activityService = _ref.read(activityServiceProvider);
      final user = await userService.getUser(userId);
      if (user != null) {
        await activityService.recordVolunteerJoined(
          user,
          userId: userId,
          userName: name,
        );
      }
    }
  }

  Future<void> _setUserOffline() async {
    final userId = _ref.read(userIdProvider);
    if (userId.isNotEmpty) {
      final userService = _ref.read(userServiceProvider);
      await userService.setOffline(userId);
    }
  }

  Future<void> logout() async {
    await _setUserOffline();
    state = UserRole.none;
    await _prefs.setString('role', 'none');
  }

  Future<void> clearSession() async {
    await _setUserOffline();
    state = UserRole.none;
    await _prefs.setString('role', 'none');
  }
}
