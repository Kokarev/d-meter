import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../state/calculator_state.dart';

class ModeSelectorWidget extends StatelessWidget {
  final CalcMode current;
  final ValueChanged<CalcMode> onChanged;

  const ModeSelectorWidget({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt = isDark ? AppColorsDark.surfaceAlt : AppColors.surfaceAlt;
    final border     = isDark ? AppColorsDark.border     : AppColors.border;
    return Container(
      decoration: BoxDecoration(
        color:        surfaceAlt,
        borderRadius: AppRadii.mdAll,
        border:       Border.all(color: border, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _Tab(
            label:  l.modeDensityAtTemp,
            active: current == CalcMode.densityAtTemp,
            onTap:  () => onChanged(CalcMode.densityAtTemp),
          ),
          _Tab(
            label:  l.modeTempAtDensity,
            active: current == CalcMode.tempAtDensity,
            onTap:  () => onChanged(CalcMode.tempAtDensity),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
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
          duration: const Duration(milliseconds: 200),
          curve:    Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            vertical:   AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active
                ? (Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.accent : AppColors.accent)
                : Colors.transparent,
            borderRadius: AppRadii.smAll,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: active ? AppText.modeActive : AppText.modeInactive,
          ),
        ),
      ),
    );
  }
}
