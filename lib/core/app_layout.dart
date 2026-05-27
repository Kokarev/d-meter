// ─────────────────────────────────────────────────────────────────────────────
// AppLayout — layout breakpoints.
// Используется для adaptive behavior (mobile vs desktop/wide).
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppLayout {
  /// Ниже этого значения — мобильный режим (bottom sheets).
  /// Выше или равно — desktop/wide режим (inline expand).
  static const double desktopBreakpoint = 600.0;

  /// Возвращает true если текущий экран считается "широким" (desktop/tablet).
  static bool isWide(double screenWidth) =>
      screenWidth >= desktopBreakpoint;
}
