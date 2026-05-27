import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_layout.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';
import 'density_details_sheet.dart';
import 'temperature_details_sheet.dart';

/// Карточка результату.
///
/// • Primary value — великий, синій, tabular figures.
/// • Secondary value — дрібний, приглушений, під розділювачем.
/// • Long-press — копіювати primary в буфер → SnackBar.
/// • Tap "Details ›" — відкрити відповідний bottom sheet.
class ResultCard extends StatelessWidget {
  final DensityResult result;
  final CalcMode      mode;

  const ResultCard({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final isDensityMode = mode == CalcMode.densityAtTemp;

    // Primary
    final primaryLabel = isDensityMode
        ? l.resultDeliveryDensity
        : l.resultDeliveryTemperature;
    final primaryValue = isDensityMode
        ? result.densityAtTempKgL.toStringAsFixed(4)
        : result.tempC.toStringAsFixed(1);
    final primaryUnit = isDensityMode ? 'kg/l' : '°C';

    // Secondary
    final secondaryLabel = isDensityMode ? l.resultVolume : l.resultWeight;
    final secondaryValue = isDensityMode
        ? result.volumeM3.toStringAsFixed(3)
        : result.weightT.toStringAsFixed(3);
    final secondaryUnit = isDensityMode ? 'm³' : 't';

    return GestureDetector(
      onLongPress: () => _copyToClipboard(context, l, primaryValue, primaryUnit),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:        AppColors.resultBg,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color:  AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Синя акцентна смуга ────────────────────────────────
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

              // ── Контент ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: AppSpacing.resultCardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Primary result ─────────────────────────────
                      Text(primaryLabel, style: AppText.resultLabel),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              primaryValue,
                              style: AppText.resultPrimary,
                            ),
                          ),
                          Text(primaryUnit, style: AppText.resultUnit),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.divider,
                      ),
                      const SizedBox(height: 6),

                      // ── Secondary result + Details link ────────────
                      Row(
                        children: [
                          // Secondary value
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  secondaryLabel,
                                  style: AppText.detailKey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$secondaryValue $secondaryUnit',
                                  style: AppText.detailValue.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Details link — только на mobile.
                          // На desktop Details раскрывается inline
                          // в DetailsPanel под ResultCard.
                          if (!AppLayout.isWide(
                            MediaQuery.of(context).size.width))
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openDetails(context),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l.detailsToggle,
                                      style: AppText.detailNote.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(
      BuildContext context, AppL10n l, String value, String unit) {
    Clipboard.setData(ClipboardData(text: '$value $unit'));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${l.detailsCopied}: $value $unit',
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
          ),
        ),
      );
  }

  void _openDetails(BuildContext context) {
    final sheet = mode == CalcMode.densityAtTemp
        ? DensityDetailsSheet(result: result, mode: mode)
        : TemperatureDetailsSheet(result: result, mode: mode);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }
}
