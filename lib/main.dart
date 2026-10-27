import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

// Entry point of the app: initializes Firebase, launches the UI, and sets up notifications.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connect the app to Firebase using the platform config.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BorrowItApp());
  // Initialize local notifications after the first frame renders.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(NotificationService.instance.init());
  });
}
