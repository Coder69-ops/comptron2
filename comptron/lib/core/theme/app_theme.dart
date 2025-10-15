import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern color palette
  static const _primaryColor = Color(0xFF6366F1); // Indigo-500
  static const _secondaryColor = Color(0xFF8B5CF6); // Violet-500
  static const _accentColor = Color(0xFF06B6D4); // Cyan-500
  static const _errorColor = Color(0xFFEF4444); // Red-500

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEEF2FF),
      onPrimaryContainer: const Color(0xFF312E81),
      secondary: _secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFF3E8FF),
      onSecondaryContainer: const Color(0xFF581C87),
      tertiary: _accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFCFFAFE),
      onTertiaryContainer: const Color(0xFF164E63),
      surface: const Color(0xFFFAFAFA),
      onSurface: const Color(0xFF1F2937),
      surfaceContainerHighest: const Color(0xFFE5E7EB),
      onSurfaceVariant: const Color(0xFF6B7280),
      error: _errorColor,
      onError: Colors.white,
      outline: const Color(0xFFD1D5DB),
      shadow: Colors.black.withValues(alpha: 0.05),
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: const Color(0xFF1F2937),
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: const Color(0xFF1F2937),
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF374151),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF374151),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B7280),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: const Color(0xFFFAFAFA),
      surfaceTintColor: Colors.transparent,
      foregroundColor: const Color(0xFF1F2937),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF6B7280), size: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.02),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        shadowColor: _primaryColor.withValues(alpha: 0.3),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
        foregroundColor: const Color(0xFF374151),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9CA3AF),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      indicatorColor: const Color(0xFFEEF2FF),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primaryColor, size: 24);
        }
        return const IconThemeData(color: Color(0xFF6B7280), size: 24);
      }),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF818CF8), // Lighter indigo for dark mode
      onPrimary: Color(0xFF1E1B4B),
      primaryContainer: Color(0xFF312E81),
      onPrimaryContainer: Color(0xFFE0E7FF),
      secondary: Color(0xFFA78BFA), // Lighter violet
      onSecondary: Color(0xFF4C1D95),
      secondaryContainer: Color(0xFF581C87),
      onSecondaryContainer: Color(0xFFF3E8FF),
      tertiary: Color(0xFF22D3EE), // Lighter cyan
      onTertiary: Color(0xFF083344),
      tertiaryContainer: Color(0xFF164E63),
      onTertiaryContainer: Color(0xFFCFFAFE),
      surface: Color(0xFF0F172A), // Dark slate
      onSurface: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFF1E293B),
      onSurfaceVariant: Color(0xFF94A3B8),
      error: Color(0xFFF87171), // Lighter red for dark mode
      onError: Color(0xFF7F1D1D),
      outline: Color(0xFF475569),
      shadow: Color(0x4D000000),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: const Color(0xFFF1F5F9),
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: const Color(0xFFF1F5F9),
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFE2E8F0),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFE2E8F0),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: const Color(0xFF0F172A),
      surfaceTintColor: Colors.transparent,
      foregroundColor: const Color(0xFFF1F5F9),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      color: const Color(0xFF1E293B),
      shadowColor: Colors.black.withValues(alpha: 0.5),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: const Color(0xFF1E1B4B),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      indicatorColor: const Color(0xFF312E81),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF818CF8),
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF818CF8), size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
    ),
  );
}
