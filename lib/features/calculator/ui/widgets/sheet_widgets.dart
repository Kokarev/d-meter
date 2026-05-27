// ─────────────────────────────────────────────────────────────────────────────
// sheet_widgets.dart
//
// Общие виджеты для DensityDetailsSheet и TemperatureDetailsSheet.
// Не содержит бизнес-логику — только UI.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';

// ─── Данные одной строки ──────────────────────────────────────────────────────

class SheetRow {
  final String label;
  final String value;
  final String unit;
  final bool   accent; // выделить значение синим

  const SheetRow({
    required this.label,
    required this.value,
    required this.unit,
    this.accent = false,
  });
}

// ─── Каркас bottom sheet ──────────────────────────────────────────────────────

class DetailsSheetScaffold extends StatelessWidget {
  final String      title;
  final String      subtitle;
  final Color       accentColor;
  final List<SheetRow> rows;
  final String      formula;

  const DetailsSheetScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.rows,
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final l  = AppL10n.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(AppRadii.xl),
          topRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 36, height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textHint,
                borderRadius: AppRadii.smAll,
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 4, height: 36,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: AppRadii.xsAll,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.resultLabel.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(subtitle, style: AppText.sectionLabel),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: AppColors.textHint),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: AppColors.divider),

          // ── Прокручиваемое тело ───────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rows.map((r) => SheetDetailRow(row: r)),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.sm),
                  SheetFormulaBlock(formula: formula, l: l),
                  SizedBox(height: AppSpacing.xl + mq.padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Строка деталей ───────────────────────────────────────────────────────────

class SheetDetailRow extends StatelessWidget {
  final SheetRow row;
  const SheetDetailRow({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.detailRowV + 1),
      child: Row(
        children: [
          Expanded(child: Text(row.label, style: AppText.detailKey)),
          Text(
            row.value,
            style: AppText.detailValue.copyWith(
              color: row.accent ? AppColors.accent : AppColors.textPrimary,
              fontWeight: row.accent ? FontWeight.w600 : FontWeight.w500,
              fontSize: row.accent ? 13 : 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: Text(
              row.unit,
              style: AppText.detailUnit,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Блок формулы ─────────────────────────────────────────────────────────────

class SheetFormulaBlock extends StatelessWidget {
  final String   formula;
  final AppL10n  l;
  const SheetFormulaBlock({super.key, required this.formula, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.formulaBg,
        borderRadius: AppRadii.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.formulaLabel, style: AppText.formulaLabel),
          const SizedBox(height: 3),
          Text(formula, style: AppText.formulaCode),
          const SizedBox(height: 2),
          const Text(
        'EN ISO 91-1 / EN ISO 12185',
            style: AppText.formulaStandard,
          ),
        ],
      ),
    );
  }
}
