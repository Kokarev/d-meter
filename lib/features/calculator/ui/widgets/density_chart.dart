import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../models/density_point.dart';
import '../../services/density_curve_service.dart';

/// График плотности vs температуры.
///
/// Отображает:
///   1. Паспортную кривую (синяя линия)
///   2. Текущую рабочую точку (красная точка + вертикальная пунктирная линия)
///   3. Опциональную точку смеси — Phase 3 (зелёная точка)
///
/// Стиль: industrial, mobile-first, без тяжёлых градиентов.
class DensityChart extends StatelessWidget {
  final List<DensityPoint> curve;
  final DensityPoint        operatingPoint;
  final DensityPoint?       mixturePoint;
  final double              height;

  const DensityChart({
    super.key,
    required this.curve,
    required this.operatingPoint,
    this.mixturePoint,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (curve.isEmpty) return const SizedBox.shrink();

    final range   = DensityCurveService.densityRange(curve);
    final minTemp = curve.first.tempC;
    final maxTemp = curve.last.tempC;

    final passportSpots = curve
        .map((p) => FlSpot(p.tempC, p.densityKgL))
        .toList();

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: LineChart(
        _buildData(
          passportSpots: passportSpots,
          range:         range,
          minTemp:       minTemp,
          maxTemp:       maxTemp,
        ),
        duration: const Duration(milliseconds: 150),
      ),
    );
  }

  LineChartData _buildData({
    required List<FlSpot>              passportSpots,
    required ({double min, double max}) range,
    required double                    minTemp,
    required double                    maxTemp,
  }) {
    final tInterval = (maxTemp - minTemp) / 6;
    final dInterval = (range.max - range.min) / 4;

    return LineChartData(
      minX: minTemp, maxX: maxTemp,
      minY: range.min, maxY: range.max,
      clipData: const FlClipData.all(),

      gridData: FlGridData(
        show: true,
        horizontalInterval: dInterval,
        verticalInterval:   tInterval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AppColors.divider, strokeWidth: 0.5),
        getDrawingVerticalLine: (_) =>
            FlLine(color: AppColors.divider, strokeWidth: 0.5),
      ),

      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: Text('°C',
              style: AppText.detailUnit.copyWith(fontSize: 10)),
          sideTitles: SideTitles(
            showTitles: true,
            interval: tInterval,
            reservedSize: 22,
            getTitlesWidget: (val, _) => Text(
              val.toStringAsFixed(0),
              style: AppText.detailUnit.copyWith(fontSize: 9),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text('kg/l',
              style: AppText.detailUnit.copyWith(fontSize: 10)),
          sideTitles: SideTitles(
            showTitles: true,
            interval: dInterval,
            reservedSize: 42,
            getTitlesWidget: (val, _) => Text(
              val.toStringAsFixed(3),
              style: AppText.detailUnit.copyWith(fontSize: 9),
            ),
          ),
        ),
        topTitles:   const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),

      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
          left:   BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),

      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.surface,
          tooltipBorder:
              const BorderSide(color: AppColors.border, width: 0.5),
          tooltipRoundedRadius: AppRadii.sm,
          getTooltipItems: (spots) => spots.map((s) {
            return LineTooltipItem(
              '${s.x.toStringAsFixed(1)}°C\n'
              '${s.y.toStringAsFixed(4)} kg/l',
              AppText.detailValue.copyWith(fontSize: 10),
            );
          }).toList(),
        ),
      ),

      lineBarsData: [
        // 1. Паспортная кривая — синяя
        LineChartBarData(
          spots:           passportSpots,
          isCurved:        true,
          curveSmoothness: 0.3,
          color:           AppColors.accent,
          barWidth:        1.5,
          dotData:         const FlDotData(show: false),
          belowBarData: BarAreaData(
            show:  true,
            color: AppColors.accent.withAlpha(15),
          ),
        ),

        // 2. Пунктирная вертикаль на рабочей точке
        LineChartBarData(
          spots: [
            FlSpot(operatingPoint.tempC, range.min),
            FlSpot(operatingPoint.tempC, range.max),
          ],
          color:     AppColors.brand.withAlpha(100),
          barWidth:  1,
          dotData:   const FlDotData(show: false),
          dashArray: [4, 4],
        ),

        // 3. Рабочая точка — красная
        LineChartBarData(
          spots: [
            FlSpot(operatingPoint.tempC, operatingPoint.densityKgL)
          ],
          color:   AppColors.brand,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius:      5,
              color:       AppColors.brand,
              strokeColor: AppColors.surface,
              strokeWidth: 2,
            ),
          ),
        ),

        // 4. Точка смеси — зелёная (Phase 3)
        if (mixturePoint != null)
          LineChartBarData(
            spots: [
              FlSpot(mixturePoint!.tempC, mixturePoint!.densityKgL)
            ],
            color:   AppColors.success,
            barWidth: 0,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius:      5,
                color:       AppColors.success,
                strokeColor: AppColors.surface,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }
}
