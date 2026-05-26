import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../service/density_calculator_service.dart';
import '../../state/calculator_state.dart';

class DetailsPanel extends StatelessWidget {
  final DensityResult result;
  final CalcMode mode;
  final bool isOpen;
  final VoidCallback onToggle;

  const DetailsPanel({
    super.key,
    required this.result,
    required this.mode,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // ── Toggle header ──────────────────────────────────────────────
          InkWell(
            onTap: onToggle,
            borderRadius: isOpen
                ? const BorderRadius.only(
                    topLeft:  Radius.circular(AppRadii.lg),
                    topRight: Radius.circular(AppRadii.lg),
                  )
                : AppRadii.lgAll,
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
                  Text(AppL10n.of(context).detailsToggle, style: AppText.resultLabel),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isOpen ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: AppL10n.of(context).detailDensityAt15,
                        value: result.densityAt15KgL.toStringAsFixed(4),
                        unit:  'kg/l',
                        note:  'EN ISO 12185',
                      ),
                      _DetailRow(
                        label: AppL10n.of(context).detailDensityInAir,
                        value: result.densityInAirKgL.toStringAsFixed(4),
                        unit:  'kg/l',
                      ),
                      _DetailRow(
                        label: AppL10n.of(context).detailDeliveryTemp,
                        value: result.tempC.toStringAsFixed(1),
                        unit:  '°C',
                      ),
                      _DetailRow(
                        label: AppL10n.of(context).detailVolume,
                        value: result.volumeM3.toStringAsFixed(3),
                        unit:  'm³',
                      ),
                      _DetailRow(
                        label: AppL10n.of(context).detailWeight,
                        value: result.weightT.toStringAsFixed(3),
                        unit:  't',
                      ),
                      _DetailRow(
                        label: AppL10n.of(context).detailCoefficientA,
                        value: result.coeffA.toStringAsFixed(1),
                        unit:  '×10⁻³/°C',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
                _FormulaBlock(mode: mode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail row ───────────────────────────────────────────────────────────────
// Fixed-width value + unit columns ensure consistent right-side alignment.

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? note;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.unit,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.detailRowV),
      child: Row(
        children: [
          // Label — left-aligned, takes remaining space
          Expanded(
            child: Text(label, style: AppText.detailKey),
          ),

          // Optional standard note, e.g. "EN ISO 12185"
          if (note != null) ...[
            Text(note!, style: AppText.detailNote),
            const SizedBox(width: AppSpacing.xs),
          ],

          // Value — right-aligned, fixed width for consistent column
          SizedBox(
            width: 64,
            child: Text(
              value,
              style: AppText.detailValue,
              textAlign: TextAlign.right,
            ),
          ),

          // Unit — fixed width, secondary color
          SizedBox(
            width: 56,
            child: Text(
              unit,
              style: AppText.detailUnit,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formula block ────────────────────────────────────────────────────────────
// Engineering reference note: compact, technical, not a debug box.

class _FormulaBlock extends StatelessWidget {
  final CalcMode mode;

  const _FormulaBlock({required this.mode});

  @override
  Widget build(BuildContext context) {
    final formula = mode == CalcMode.densityAtTemp
        ? 'Pt = P15 − a × (t − 15) / 1000'
        : 't = (P15 − Pt × 1000) / a + 15';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.formulaBg,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(AppRadii.lg),
          bottomRight: Radius.circular(AppRadii.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "FORMULA" micro-label
          Text(AppL10n.of(context).formulaLabel, style: AppText.formulaLabel),
          const SizedBox(height: 3),
          // The actual formula — monospace, blue, readable
          Text(formula, style: AppText.formulaCode),
          const SizedBox(height: 2),
          // Standard reference — quiet
          const Text('EN ISO 91-1 / EN ISO 12185', style: AppText.formulaStandard),
        ],
      ),
    );
  }
}
