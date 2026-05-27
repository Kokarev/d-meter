import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';
import '../../../../core/tokens.dart';
import 'sheet_widgets.dart';

/// Bottom sheet — Mode A (Density at temperature).
/// Показывает все детали расчёта: густини, температуру, об'єм, масу, коефіцієнт, формулу.
class DensityDetailsSheet extends StatelessWidget {
  final DensityResult result;
  final CalcMode      mode;

  const DensityDetailsSheet({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return DetailsSheetScaffold(
      title:       l.resultDeliveryDensity,
      subtitle:    l.modeDensityAtTemp,
      accentColor: AppColors.accent,
      formula:     'Pt = P15 − a × (t − 15) / 1000',
      rows: [
        SheetRow(
          label:  l.resultDeliveryDensity,
          value:  result.densityAtTempKgL.toStringAsFixed(4),
          unit:   'kg/l',
          accent: true,
        ),
        SheetRow(
          label: l.detailDensityAt15,
          value: result.densityAt15KgL.toStringAsFixed(4),
          unit:  'kg/l',
        ),
        SheetRow(
          label: l.detailDensityInAir,
          value: result.densityInAirKgL.toStringAsFixed(4),
          unit:  'kg/l',
        ),
        SheetRow(
          label: l.detailContractDensity,
          value: result.contractDensityKgL.toStringAsFixed(4),
          unit:  'kg/l',
        ),
        SheetRow(
          label: l.detailDeliveryTemp,
          value: result.tempC.toStringAsFixed(1),
          unit:  '°C',
        ),
        SheetRow(
          label:  l.detailVolume,
          value:  result.volumeM3.toStringAsFixed(3),
          unit:   'm³',
          accent: true,
        ),
        SheetRow(
          label: l.detailWeight,
          value: result.weightT.toStringAsFixed(3),
          unit:  't',
        ),
        SheetRow(
          label: l.detailCoefficientA,
          value: result.coeffA.toStringAsFixed(1),
          unit:  '×10⁻³/°C',
        ),
      ],
    );
  }
}
