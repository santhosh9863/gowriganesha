import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

  Future<void> setCredentials(UserRole role, String name) async {
    _ref.read(userNameProvider.notifier).state = name;
    await _prefs.setString('userName', name);
    state = role;
    await _prefs.setString('role', role.name);
  }

  Future<bool> loginAsAdmin(String password, {String? userName}) async {
    final service = _ref.read(firestoreProvider);
    final storedHash = await service.getAdminPasswordHash();
    if (storedHash == null) {
      await service.setAdminPasswordHash(_hashPassword(password));
      if (userName != null) await setUserName(userName);
      await setRole(UserRole.admin);
      return true;
    }
    if (storedHash == _hashPassword(password)) {
      if (userName != null) await setUserName(userName);
      await setRole(UserRole.admin);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    state = UserRole.volunteer;
    await _prefs.setString('role', 'volunteer');
  }
}
