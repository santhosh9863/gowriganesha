import 'dart:ui';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganesha_2026/app.dart';
import 'package:ganesha_2026/firebase_options.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[GLOBAL_ERR] FlutterError: ${details.exception}');
    debugPrint('[GLOBAL_ERR] Stack: ${details.stack}');
    FlutterError.dumpErrorToConsole(details);
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[GLOBAL_ERR] PlatformDispatcher error: $error');
    debugPrint('[GLOBAL_ERR] Stack: $stack');
    if (kDebugMode) return false;
    return true;
  };

  debugPrint('[FIREBASE] Initialization started');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('[FIREBASE] Initialized');

  await FirebaseAuth.instance.signInAnonymously();
  debugPrint('[AUTH] Signed in anonymously');

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const GaneshaApp(),
    ),
  );
}
