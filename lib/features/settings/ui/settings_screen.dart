import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/state/locale_state.dart';
import '../../../shared/state/theme_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = info.version);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l           = AppL10n.of(context);
    final localeState = context.watch<LocaleState>();
    final themeState  = context.watch<ThemeState>();
    final currentCode =
        localeState.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            _SettingsHeader(title: l.menuSettings),

            // ── Body ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // ── Language section ─────────────────────
                  _SectionLabel(l.menuLanguage.toUpperCase()),
                  const SizedBox(height: AppSpacing.xs),
                  _LanguageSelector(
                    currentCode:  currentCode,
                    localeState:  localeState,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Theme section ────────────────────────
                  const _SectionLabel('APPEARANCE'),
                  const SizedBox(height: AppSpacing.xs),
                  _ThemeSelector(themeState: themeState),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── App section ──────────────────────────
                  const _SectionLabel('APP'),
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(
                    label: 'Version',
                    value: _version.isEmpty ? '…' : _version,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const _InfoRow(
                    label: 'Standard',
                    value: 'EN ISO 91-1 / EN ISO 12185',
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadii.smAll,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color:        AppColors.accentBg,
                  borderRadius: AppRadii.smAll,
                  border: Border.all(
                    color: AppColors.accent.withAlpha(60), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: AppText.sectionLabel.copyWith(
              fontSize: 13, letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language selector ────────────────────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  final String      currentCode;
  final LocaleState localeState;

  const _LanguageSelector({
    required this.currentCode,
    required this.localeState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          _LangButton(
            label:    'EN',
            active:   currentCode == 'en',
            onTap:    () => localeState.setLocale(const Locale('en')),
          ),
          _LangButton(
            label:    'УК',
            active:   currentCode == 'uk',
            onTap:    () => localeState.setLocale(const Locale('uk')),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:        active ? AppColors.accentBg : Colors.transparent,
            borderRadius: AppRadii.mdAll,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.dropdownItem.copyWith(
              color:      active ? AppColors.accent : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Theme selector ──────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ThemeState themeState;
  const _ThemeSelector({required this.themeState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          _ThemeButton(
            label:  '☀️',
            hint:   'Light',
            active: themeState.mode == ThemeMode.light,
            onTap:  () => themeState.setMode(ThemeMode.light),
          ),
          _ThemeButton(
            label:  '⚙️',
            hint:   'System',
            active: themeState.mode == ThemeMode.system,
            onTap:  () => themeState.setMode(ThemeMode.system),
          ),
          _ThemeButton(
            label:  '🌙',
            hint:   'Dark',
            active: themeState.mode == ThemeMode.dark,
            onTap:  () => themeState.setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String       label;
  final String       hint;
  final bool         active;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.hint,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:        active ? AppColors.accentBg : Colors.transparent,
            borderRadius: AppRadii.mdAll,
            border: active
                ? Border.all(
                    color: AppColors.accent.withAlpha(60), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                hint,
                style: AppText.detailUnit.copyWith(
                  color: active
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.sectionLabel);
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.detailRowV),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.detailKey)),
          Text(value, style: AppText.detailValue),
        ],
      ),
    );
  }
}
