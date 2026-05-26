import 'package:flutter/material.dart';
import '../../../../core/fuel_grade.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';

class FuelDropdown extends StatelessWidget {
  final FuelGrade selected;
  final ValueChanged<FuelGrade> onChanged;

  const FuelDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.mdAll,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected.name,
                style: AppText.dropdownItem.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final items = <PopupMenuEntry<FuelGrade>>[];

    for (final group in FuelProductGroup.values) {
      final grades = kFuelGrades.where((f) => f.group == group).toList();
      if (grades.isEmpty) continue;

      final l = AppL10n.of(context);
      final groupLabel = switch (group) {
        FuelProductGroup.gasoil   => l.fuelGroupGasoil,
        FuelProductGroup.gasoline => l.fuelGroupGasoline,
      };

      items.add(
        PopupMenuItem<FuelGrade>(
          enabled: false,
          height:  32,
          child: Text(groupLabel.toUpperCase(), style: AppText.sectionLabel),
        ),
      );

      for (final grade in grades) {
        items.add(
          PopupMenuItem<FuelGrade>(
            value: grade,
            child: _FuelMenuItem(
              grade: grade,
              isSelected: grade.id == selected.id,
            ),
          ),
        );
      }
    }

    final FuelGrade? picked = await showMenu<FuelGrade>(
      context: context,
      position: position,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
      color: AppColors.surface,
      elevation: 4,
      items: items,
    );

    if (picked != null) onChanged(picked);
  }
}

class _FuelMenuItem extends StatelessWidget {
  final FuelGrade grade;
  final bool isSelected;

  const _FuelMenuItem({
    required this.grade,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                grade.name,
                style: AppText.dropdownItem.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              Text(grade.standard, style: AppText.sectionLabel),
            ],
          ),
        ),
        if (isSelected)
          const Icon(Icons.check_rounded, size: 16, color: AppColors.accent),
      ],
    );
  }
}
