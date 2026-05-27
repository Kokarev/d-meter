import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';
import '../../../../core/tokens.dart';
import 'sheet_widgets.dart';

/// Bottom sheet — Mode B (Temperature at density).
class TemperatureDetailsSheet extends StatelessWidget {
  final DensityResult result;
  final CalcMode      mode;

  const TemperatureDetailsSheet({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return DetailsSheetScaffold(
      title:       l.resultDeliveryTemperature,
      subtitle:    l.modeTempAtDensity,
      accentColor: AppColors.brand,
      formula:     't = (P15 − Pt × 1000) / a + 15',
      rows: [
        SheetRow(
          label:  l.resultDeliveryTemperature,
          value:  result.tempC.toStringAsFixed(1),
          unit:   '°C',
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
          label: l.detailVolume,
          value: result.volumeM3.toStringAsFixed(3),
          unit:  'm³',
        ),
        SheetRow(
          label:  l.detailWeight,
          value:  result.weightT.toStringAsFixed(3),
          unit:   't',
          accent: true,
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
