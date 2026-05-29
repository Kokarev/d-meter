// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — Step 1: foundation only.
//
// Provides AppTheme.light and AppTheme.dark ThemeData.
// ThemeMode is NOT set to system yet — screens still use AppColors.* directly.
// This file is infrastructure only.
//
// Next step: replace AppColors.* hardcodes in UI with Theme.of(context) values,
// then switch main.dart to ThemeMode.system.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'tokens.dart';

abstract final class AppTheme {
  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary:        AppColors.accent,
      primaryContainer: AppColors.accentBg,
      error:          AppColors.danger,
      surface:        AppColors.surface,
      onSurface:      AppColors.textPrimary,
      onPrimary:      Colors.white,
      outline:        AppColors.border,
    ),
    inputDecorationTheme: _inputTheme(
      border:      AppColors.border,
      focus:       AppColors.borderFocus,
      label:       AppColors.textSecondary,
      hint:        AppColors.textHint,
      value:       AppColors.textPrimary,
      background:  AppColors.surface,
    ),
    dividerColor: AppColors.divider,
    cardColor:    AppColors.surface,
  );

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.background,
    colorScheme: const ColorScheme.dark(
      primary:        AppColorsDark.accent,
      primaryContainer: AppColorsDark.accentBg,
      error:          AppColorsDark.danger,
      surface:        AppColorsDark.surface,
      onSurface:      AppColorsDark.textPrimary,
      onPrimary:      Colors.white,
      outline:        AppColorsDark.border,
    ),
    inputDecorationTheme: _inputTheme(
      border:      AppColorsDark.border,
      focus:       AppColorsDark.borderFocus,
      label:       AppColorsDark.textSecondary,
      hint:        AppColorsDark.textHint,
      value:       AppColorsDark.textPrimary,
      background:  AppColorsDark.surface,
    ),
    dividerColor: AppColorsDark.divider,
    cardColor:    AppColorsDark.surface,
  );

  // ── Shared helpers ─────────────────────────────────────────────────────────
  static InputDecorationTheme _inputTheme({
    required Color border,
    required Color focus,
    required Color label,
    required Color hint,
    required Color value,
    required Color background,
  }) =>
      InputDecorationTheme(
        filled: true,
        fillColor: background,
        labelStyle: TextStyle(color: label, fontSize: 12),
        hintStyle:  TextStyle(color: hint,  fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: focus, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.danger, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical:   AppSpacing.inputPadV,
        ),
      );
}
