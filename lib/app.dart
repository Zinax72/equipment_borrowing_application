import 'package:flutter/material.dart';
import 'screens/auth/auth_gate.dart';
import 'utils/constants.dart';

// Root widget that configures the app-wide theme, colors, input styles, and starting screen.
class BorrowItApp extends StatelessWidget {
  const BorrowItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BorrowIT - BulSU Equipment',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        // Main BulSU color scheme (Maroon and Gold).
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.universityRed,
          primary: AppColors.universityRed,
          secondary: AppColors.gold,
          tertiary: AppColors.gold,
          surface: Colors.white,
        ).copyWith(
          onSurface: AppColors.darkText,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: AppColors.canvas,
          surfaceContainer: AppColors.field,
          error: AppColors.brightRed,
        ),
        fontFamily: 'Roboto',
        // Transparent app bar style used across screens.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.darkText,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        // Default styling for all text fields and forms.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.65),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: AppColors.subtleText,
            fontWeight: FontWeight.w400,
          ),
          prefixIconColor: AppColors.universityRed,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.universityRed,
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.brightRed, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.brightRed, width: 1.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.universityRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 52),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.universityRed,
            minimumSize: const Size(44, 44),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkText.withValues(alpha: 0.92),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Bottom navigation bar colors and selected state styles.
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.universityRed.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.universityRed
                  : AppColors.mutedText,
              size: 22,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.universityRed
                  : AppColors.mutedText,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w500,
              fontSize: 11.5,
              letterSpacing: -0.1,
            );
          }),
        ),
      ),
      // AuthGate decides whether to show LandingScreen or HomeScreen.
      home: const AuthGate(),
    );
  }
}
