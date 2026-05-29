import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
abstract final class AppColors {
  // Brand
  static const Color brand      = Color(0xFFE24B4A); // D-METER red (logo only)
  static const Color accent     = Color(0xFF378ADD); // primary blue
  static const Color accentBg   = Color(0xFFEEF5FC); // very light blue tint

  // Surface
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F1F3); // pill/toggle track
  static const Color background = Color(0xFFF6F7F9); // neutral light gray

  // Cards
  static const Color cardSurface  = Color(0xFFFFFFFF);
  static const Color resultBg     = Color(0xFFFFFFFF); // white result card
  static const Color resultBorder = Color(0xFF378ADD); // blue accent line
  static const Color formulaBg    = Color(0xFFF3F7FB); // subtle blue-gray
  static const Color shadow       = Color(0x08000000); // 3% black shadow

  // Text
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280); // slightly cooler gray
  static const Color textHint      = Color(0xFFB0B7C3); // lighter hint

  // Border
  static const Color border      = Color(0xFFE5E7EB); // softer border
  static const Color borderFocus = Color(0xFF378ADD);
  static const Color divider     = Color(0xFFEDF0F3);

  // Status
  static const Color success = Color(0xFF4A9960);
  static const Color warning = Color(0xFFB07D2A);
  static const Color danger  = Color(0xFFD94040);
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
abstract final class AppText {
  static const String _font = 'Roboto';

  // ── Logo ──
  static const TextStyle logoD = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static const TextStyle logoMeter = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.brand,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static const TextStyle logoSub = TextStyle(
    fontFamily: _font,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    letterSpacing: 0.6,
  );

  // ── Chrome ──
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.8,
  );

  // ── Inputs ──
  // Slightly lighter than before — readable but not heavy
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle inputValue = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputUnit = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ── Result card ──
  static const TextStyle resultPrimary = TextStyle(
    fontFamily: _font,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle resultUnit = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.1,
  );

  static const TextStyle resultLabel = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  // ── Details panel ──
  // Labels: lighter weight, secondary color
  static const TextStyle detailKey = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Values: medium weight, primary color, tabular figures
  static const TextStyle detailValue = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.4,
  );

  static const TextStyle detailUnit = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static const TextStyle detailNote = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // ── Formula block ──
  static const TextStyle formulaLabel = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.6,
  );

  static const TextStyle formulaCode = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    height: 1.5,
  );

  static const TextStyle formulaStandard = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0.1,
  );

  // ── Mode selector ──
  static const TextStyle modeActive = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle modeInactive = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Dropdowns / menus ──
  static const TextStyle dropdownItem = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle menuItem = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────────────────
abstract final class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;

  // Field-to-field vertical gap (tighter than md)
  static const double fieldGap = 10;

  // Vertical padding inside input fields (~10% less than sm)
  static const double inputPadV = 7;

  // Vertical padding inside compact detail rows
  static const double detailRowV = 4;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Cards: tighter vertical than before (12→10)
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: 10);

  // Result card: slightly more breathing room on top/bottom
  static const EdgeInsets resultCardPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: 14);

  static const EdgeInsets sectionPadding = EdgeInsets.only(bottom: lg);
}

// ─── Radii ────────────────────────────────────────────────────────────────────
abstract final class AppRadii {
  // Reduced slightly for a crisper industrial feel
  static const double xs   = 4;
  static const double sm   = 5;
  static const double md   = 7;   // inputs (was 8)
  static const double lg   = 10;  // cards  (was 12)
  static const double xl   = 14;  // drawer (was 16)
  static const double pill = 20;

  static const BorderRadius xsAll  = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll  = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll  = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll  = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll  = BorderRadius.all(Radius.circular(xl));
}

// ─── Dark Theme Colors ────────────────────────────────────────────────────────
// Step 1: foundation only. Not active until screens are theme-aware.
// Usage: AppColorsDark.background, etc. — parallel to AppColors.
abstract final class AppColorsDark {
  // Brand (unchanged — logo identity)
  static const Color brand      = Color(0xFFE24B4A);
  static const Color accent     = Color(0xFF5B9FE8); // lighter blue for dark bg
  static const Color accentBg   = Color(0xFF1A2535);

  // Surface
  static const Color surface    = Color(0xFF1C1F26);
  static const Color surfaceAlt = Color(0xFF252830); // toggle track, pill
  static const Color background = Color(0xFF0F1117); // near-black, not pure

  // Cards
  static const Color cardSurface  = Color(0xFF1C1F26);
  static const Color resultBg     = Color(0xFF1C1F26);
  static const Color resultBorder = Color(0xFF5B9FE8);
  static const Color formulaBg    = Color(0xFF1A2030); // blue-tinted dark
  static const Color shadow       = Color(0x18000000);

  // Text
  static const Color textPrimary   = Color(0xFFE8EAF0);
  static const Color textSecondary = Color(0xFF9BA3AF);
  static const Color textHint      = Color(0xFF4B5563);

  // Border
  static const Color border      = Color(0xFF2D3139);
  static const Color borderFocus = Color(0xFF5B9FE8);
  static const Color divider     = Color(0xFF252830);

  // Status
  static const Color success = Color(0xFF5AAF72);
  static const Color warning = Color(0xFFD4A03A); // thermal expansion
  static const Color danger  = Color(0xFFE55555);

  // Chart-specific
  // Operating point (🔵 blue) — brighter in dark mode for readability
  static const Color chartOperating  = Color(0xFF5B9FE8);
  // Reference point (🔴 red) — unchanged
  static const Color chartReference  = Color(0xFFE24B4A);
  // Grid lines — subtle in dark
  static const Color chartGrid       = Color(0xFF2D3139);
  // Chart fill area below curve
  static const Color chartFill       = Color(0x225B9FE8); // alpha 34
}

