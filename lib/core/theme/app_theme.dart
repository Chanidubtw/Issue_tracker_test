import 'package:flutter/material.dart';

class AppTheme {
  static const _primarySeed = Color(0xFF4F6AF5);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: base.surface,
        foregroundColor: base.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: base.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: base.surface,
        foregroundColor: base.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: base.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: base.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Color statusColor(String status, ColorScheme cs) {
    switch (status) {
      case 'open':
        return cs.brightness == Brightness.light
            ? const Color(0xFF2196F3)
            : const Color(0xFF90CAF9);
      case 'in_progress':
        return cs.brightness == Brightness.light
            ? const Color(0xFFFF9800)
            : const Color(0xFFFFCC80);
      case 'resolved':
        return cs.brightness == Brightness.light
            ? const Color(0xFF4CAF50)
            : const Color(0xFFA5D6A7);
      case 'closed':
        return cs.brightness == Brightness.light
            ? const Color(0xFF9E9E9E)
            : const Color(0xFFE0E0E0);
      default:
        return cs.outline;
    }
  }

  static Color priorityColor(String priority, ColorScheme cs) {
    switch (priority) {
      case 'critical':
        return cs.brightness == Brightness.light
            ? const Color(0xFFF44336)
            : const Color(0xFFEF9A9A);
      case 'high':
        return cs.brightness == Brightness.light
            ? const Color(0xFFFF7043)
            : const Color(0xFFFFAB91);
      case 'medium':
        return cs.brightness == Brightness.light
            ? const Color(0xFFFF9800)
            : const Color(0xFFFFCC80);
      case 'low':
        return cs.brightness == Brightness.light
            ? const Color(0xFF66BB6A)
            : const Color(0xFFA5D6A7);
      default:
        return cs.outline;
    }
  }
}
