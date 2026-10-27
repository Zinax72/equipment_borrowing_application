import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'landing_screen.dart';

// Listens to Firebase auth state and routes the user to HomeScreen (if signed in) or LandingScreen (if signed out).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authChanges,
      builder: (context, snapshot) {
        // Show a loading spinner while checking initial login state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // User is logged in: go to main HomeScreen.
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // User is logged out: show LandingScreen.
        return const LandingScreen();
      },
    );
  }
}
