import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../features/calculator/ui/widgets/dmeter_logo.dart';

class AppHeader extends StatelessWidget {
  final String? title;

  const AppHeader({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const DmeterLogo(),

          if (title != null) ...[
            const SizedBox(width: 14),

            Text(
              title!,
              style: AppText.sectionLabel.copyWith(
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ],

          const Spacer(),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadii.smAll,
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: AppRadii.smAll,
                  border: Border.all(
                    color: AppColors.accent.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  size: 17,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
