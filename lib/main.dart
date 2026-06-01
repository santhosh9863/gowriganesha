import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganesha_2026/app.dart';
import 'package:ganesha_2026/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[FIREBASE] Initialization started');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously();

  debugPrint('[FIREBASE] Anonymous auth established');

  runApp(
    const ProviderScope(
      child: GaneshaApp(),
    ),
  );

  debugPrint('[FIREBASE] App started');
}
