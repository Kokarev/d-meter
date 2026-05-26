import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';

class ResultCard extends StatelessWidget {
  final DensityResult result;
  final CalcMode mode;

  const ResultCard({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final l        = AppL10n.of(context);
    final isPrimary = mode == CalcMode.densityAtTemp;
    final label  = isPrimary ? l.resultDeliveryDensity : l.resultDeliveryTemperature;
    final value  = isPrimary
        ? result.densityAtTempKgL.toStringAsFixed(4)
        : result.tempC.toStringAsFixed(1);
    final unit   = isPrimary ? 'kg/l' : '°C';

    return Container(
      width: double.infinity,
      // White card with a thin blue left accent line — matches D-METER language
      decoration: BoxDecoration(
        color: AppColors.resultBg,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blue accent bar — thin, precise, purposeful
            Container(
              width: 3,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft:    Radius.circular(AppRadii.lg),
                  bottomLeft: Radius.circular(AppRadii.lg),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: AppSpacing.resultCardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: AppText.resultLabel),
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(value, style: AppText.resultPrimary),
                              const SizedBox(width: 5),
                              Text(unit, style: AppText.resultUnit),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Fuel-family badge — quiet but informative
                    const _ResultIcon(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.accentBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 16,
        color: AppColors.accent,
      ),
    );
  }
}
