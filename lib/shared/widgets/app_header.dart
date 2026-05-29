import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../features/calculator/ui/widgets/dmeter_logo.dart';
import '../state/locale_state.dart';

class AppHeader extends StatelessWidget {
  final String? title;

  const AppHeader({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final compactMode = screenWidth < 360;
    final ultraCompactMode = screenWidth < 220;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColorsDark.surface : AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── Logo ──────────────────────────────────────
          const DmeterLogo(),

          // ── Title ─────────────────────────────────────
          if (!compactMode && title != null) ...[
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppText.sectionLabel.copyWith(
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],

          // ── Right Controls ────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Locale Toggle ───────────────────────
                if (!ultraCompactMode) ...[
                  const _LocaleToggle(),
                  const SizedBox(width: AppSpacing.sm),
                ],

                // ── Menu Button ─────────────────────────
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadii.smAll,
                    onTap: () =>
                        Scaffold.maybeOf(context)?.openDrawer(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark ? AppColorsDark.accentBg : AppColors.accentBg,
                        borderRadius: AppRadii.smAll,
                        border: Border.all(
                          color: (isDark ? AppColorsDark.accent : AppColors.accent)
                              .withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.menu_rounded,
                        size: 17,
                        color: isDark ? AppColorsDark.accent : AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locale Toggle
// ─────────────────────────────────────────────────────────────────────────────

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle();

  @override
  Widget build(BuildContext context) {
    final localeState = context.watch<LocaleState>();

    final resolvedCode =
        localeState.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    final isUk = resolvedCode == 'uk';

    final label =
        localeState.displayCode(resolvedCode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.smAll,
        onTap: () => localeState.setLocale(
          isUk
              ? const Locale('en')
              : const Locale('uk'),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColorsDark.accentBg : AppColors.accentBg,
            borderRadius: AppRadii.smAll,
            border: Border.all(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent : AppColors.accent).withAlpha(60),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppText.sectionLabel.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent : AppColors.accent,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
