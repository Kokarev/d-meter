import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../l10n/app_localizations.dart';

/// D-METER logo — renders purely with Flutter text widgets.
/// No SVG, no images; fully scalable.
class DmeterLogo extends StatelessWidget {
  const DmeterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('D-',    style: AppText.logoD),
            Text('METER', style: AppText.logoMeter),
          ],
        ),
        // "Fuel Density" subtitle — localized
        Text(AppL10n.of(context).logoSubtitle, style: AppText.logoSub),
      ],
    );
  }
}
