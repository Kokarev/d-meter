import 'package:flutter/material.dart';
import '../../../core/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../calculator/ui/calculator_screen.dart';
import '../escalation/ui/escalation_screen.dart';

enum MenuAction {
  densityCalculator,
  escalation,
  howToUse,
  history,
  fuelStandards,
  settings,
  language,
  about,
}

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight:    Radius.circular(AppRadii.xl),
          bottomRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text('D-',    style: AppText.logoD),
                      Text('METER', style: AppText.logoMeter),
                    ],
                  ),
                  Text(l.logoSubtitle, style: AppText.logoSub),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),

            _MenuItem(
              icon:   Icons.calculate_outlined,
              label:  l.menuDensityCalculator,
              action: MenuAction.densityCalculator,
            ),
            _MenuItem(
              icon:   Icons.trending_up_rounded,
              label:  l.menuEscalation,
              action: MenuAction.escalation,
            ),

            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),

            _MenuItem(
              icon:   Icons.help_outline_rounded,
              label:  l.menuHowToUse,
              action: MenuAction.howToUse,
            ),
            _MenuItem(
              icon:   Icons.history_rounded,
              label:  l.menuHistory,
              action: MenuAction.history,
            ),
            _MenuItem(
              icon:   Icons.science_outlined,
              label:  l.menuFuelStandards,
              action: MenuAction.fuelStandards,
            ),
            _MenuItem(
              icon:   Icons.settings_outlined,
              label:  l.menuSettings,
              action: MenuAction.settings,
            ),
            _MenuItem(
              icon:   Icons.language_rounded,
              label:  l.menuLanguage,
              action: MenuAction.language,
            ),

            const Spacer(),

            const Divider(height: 1, color: AppColors.border),
            _MenuItem(
              icon:   Icons.info_outline_rounded,
              label:  l.menuAbout,
              action: MenuAction.about,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData  icon;
  final String    label;
  final MenuAction action;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.textSecondary),
      title:   Text(label, style: AppText.menuItem),
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 2),
      onTap: () {
        Navigator.of(context).pop();
        _handleAction(context, action);
      },
    );
  }

  void _handleAction(BuildContext context, MenuAction action) {
    final l = AppL10n.of(context);
    switch (action) {
      case MenuAction.densityCalculator:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CalculatorScreen()),
          (route) => false,
        );
        return;

      case MenuAction.escalation:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EscalationScreen()),
          (route) => false,
        );
        return;

      case MenuAction.howToUse:
        _showMessage(context, l.snackHowToUse);
        return;

      case MenuAction.history:
        _showMessage(context, l.snackHistory);
        return;

      case MenuAction.fuelStandards:
        _showMessage(context, l.snackFuelStandards);
        return;

      case MenuAction.settings:
        _showMessage(context, l.snackSettings);
        return;

      case MenuAction.language:
        _showMessage(context, l.snackLanguage);
        return;

      case MenuAction.about:
        _showMessage(context, l.snackAbout);
        return;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Text(message),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
