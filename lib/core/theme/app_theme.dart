import 'package:flutter/material.dart';

/// MindCare palette — calm trust (teal), slate depth, amber hope (sparingly), rose crisis only.
/// Contrast: body text targets ≥4.5:1 on light backgrounds; reading uses off-white [mist].
class AppColors {
  AppColors._();

  /// Primary CTAs & key actions — teal-500 / teal-600 (calm, trust).
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF5EEAD4);

  /// Soft companion for gradients / secondary fills (teal-tinted, not neon).
  static const Color sky = Color(0xFFCCFBF1);
  static const Color skySoft = Color(0xFFE0F2F1);

  /// Backgrounds — slate neutrals (avoid pure white for long reading on [mist]).
  static const Color mist = Color(0xFFFAFAFA);
  static const Color cloud = Color(0xFFF1F5F9);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// Text — slate-900 / slate-600.
  static const Color ink = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF475569);
  static const Color slateSecondary = Color(0xFF64748B);

  static const Color line = Color(0xFFE2E8F0);

  /// Warmth / hope — use sparingly (highlights, positive reinforcement).
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberSoft = Color(0xFFFEF3C7);

  /// Crisis & true warnings only — rose (not for general UI).
  static const Color crisis = Color(0xFFE11D48);
  static const Color crisisSoft = Color(0xFFFFE4E6);

  /// Same as [crisis] — kept for existing call sites.
  static const Color error = crisis;
  static const Color errorSoft = crisisSoft;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      primaryContainer: AppColors.sky,
      onPrimaryContainer: AppColors.tealDark,
      secondary: AppColors.slateSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.cloud,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.amber,
      onTertiary: AppColors.ink,
      error: AppColors.crisis,
      onError: Colors.white,
      surface: AppColors.surfaceCard,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      outline: AppColors.line,
      shadow: AppColors.ink.withValues(alpha: 0.08),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.mist,
      fontFamily: 'Roboto',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.crisis),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.tealDark),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.ink.withValues(alpha: 0.06)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF0F172A);
    const surface = Color(0xFF1E293B);
    const onSurface = Color(0xFFF1F5F9);
    const onMuted = Color(0xFF94A3B8);
    const primaryDark = Color(0xFF2DD4BF);
    final base = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF134E4A),
      onPrimaryContainer: Color(0xFFCCFBF1),
      secondary: onMuted,
      onSecondary: bg,
      secondaryContainer: surface,
      onSecondaryContainer: onSurface,
      tertiary: Color(0xFFFBBF24),
      onTertiary: bg,
      error: Color(0xFFFB7185),
      onError: Color(0xFF450A0A),
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onMuted,
      outline: Color(0xFF334155),
      shadow: Colors.black54,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDark, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x22FFFFFF)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
