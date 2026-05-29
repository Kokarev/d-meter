import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../calculator/ui/calculator_screen.dart';
import '../escalation/ui/escalation_screen.dart';
import '../settings/ui/settings_screen.dart';
import '../visualization/ui/density_visualization_screen.dart';

enum MenuAction {
  densityCalculator,
  densityChart,
  escalation,
  howToUse,
  history,
  fuelStandards,
  settings,
  language,
  about,
}

class AppMenuDrawer extends StatefulWidget {
  const AppMenuDrawer({super.key});

  @override
  State<AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends State<AppMenuDrawer> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadii.xl),
          bottomRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('D-', style: AppText.logoD),
                      Text('METER', style: AppText.logoMeter),
                    ],
                  ),
                  Text(
                    l.logoSubtitle,
                    style: AppText.logoSub,
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),

            // ── Navigation items ──────────────────────────
            _MenuItem(
              icon: Icons.calculate_outlined,
              label: l.menuDensityCalculator,
              action: MenuAction.densityCalculator,
            ),

            _MenuItem(
              icon: Icons.show_chart_rounded,
              label: l.vizScreenTitle,
              action: MenuAction.densityChart,
            ),

            _MenuItem(
              icon: Icons.trending_up_rounded,
              label: l.menuEscalation,
              action: MenuAction.escalation,
            ),

            const Divider(height: 1, color: AppColors.border),

            _MenuItem(
              icon: Icons.settings_outlined,
              label: l.menuSettings,
              action: MenuAction.settings,
            ),

            const Spacer(),

            Padding(
              padding: AppSpacing.screenPadding,
              child: Text(
                _version.isEmpty ? '' : 'v$_version',
                style: AppText.detailValue.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final MenuAction action;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);

          switch (action) {
            case MenuAction.densityCalculator:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CalculatorScreen(),
                ),
              );
              return;

            case MenuAction.densityChart:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const DensityVisualizationScreen(),
                ),
              );
              return;

            case MenuAction.escalation:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EscalationScreen(),
                ),
              );
              return;

            case MenuAction.settings:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
              return;

            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(label)),
              );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppText.dropdownItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
