import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';
import 'density_details_sheet.dart';
import 'temperature_details_sheet.dart';

/// Details panel.
///
/// В v1.2.3 использовался inline expand/collapse (AnimatedCrossFade).
/// В feature/mobile-instrument-ui заменён на кнопку которая открывает
/// соответствующий bottom sheet — DensityDetailsSheet или TemperatureDetailsSheet.
///
/// Внешний интерфейс (isOpen, onToggle) сохранён для совместимости
/// с calculator_screen.dart — они просто больше не используются для
/// inline анимации, но не ломают вызывающий код.
class DetailsPanel extends StatelessWidget {
  final DensityResult  result;
  final CalcMode       mode;
  final bool           isOpen;   // зарезервировано, не удалять
  final VoidCallback   onToggle; // зарезервировано, не удалять

  const DetailsPanel({
    super.key,
    required this.result,
    required this.mode,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: () => _openSheet(context),
        borderRadius: AppRadii.lgAll,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              const Icon(
                Icons.expand_circle_down_outlined,
                size: 15,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(l.detailsToggle, style: AppText.resultLabel),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
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
