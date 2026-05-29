import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../models/density_point.dart';
import '../../services/density_curve_service.dart';

/// График плотности vs температуры.
///
/// Отображает:
///   1. Паспортную кривую (синяя линия)
///   2. 🔵 Операционную точку (синяя, движется со слайдером)
///   3. 🔴 Паспортную точку P15 @ 15°C (красная, фиксирована)
///   4. Опциональную точку смеси — Phase 3 (зелёная точка)
///
/// Theme-aware: читает brightness из BuildContext.
/// Light — AppColors.*, Dark — AppColorsDark.*
/// Расчётная логика и публичный API не изменены.
class DensityChart extends StatelessWidget {
  final List<DensityPoint> curve;

  /// 🔵 Синяя точка — операционная плотность при delivery temperature.
  /// Движется при изменении слайдера температуры.
  final DensityPoint operatingPoint;

  /// 🔴 Красная точка — паспортная плотность P15 при 15°C.
  /// Фиксирована, изменяется только при редактировании P15.
  final DensityPoint referencePoint;

  final DensityPoint? mixturePoint;
  final double height;

  const DensityChart({
    super.key,
    required this.curve,
    required this.operatingPoint,
    required this.referencePoint,
    this.mixturePoint,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (curve.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _ChartColors(isDark);

    final range    = DensityCurveService.densityRange(curve);
    final minTemp  = curve.first.tempC;
    final maxTemp  = curve.last.tempC;
    final passportSpots =
        curve.map((p) => FlSpot(p.tempC, p.densityKgL)).toList();

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color:        colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: LineChart(
        _buildData(
          passportSpots: passportSpots,
          range:         range,
          minTemp:       minTemp,
          maxTemp:       maxTemp,
          colors:        colors,
        ),
        duration: const Duration(milliseconds: 150),
      ),
    );
  }

  LineChartData _buildData({
    required List<FlSpot>           passportSpots,
    required ({double min, double max}) range,
    required double                 minTemp,
    required double                 maxTemp,
    required _ChartColors           colors,
  }) {
    final tInterval = (maxTemp - minTemp) / 6;
    // 5 делений по оси Y — достаточный зазор между подписями
    final dInterval = (range.max - range.min) / 5;

    final axisLabelStyle = TextStyle(
      fontSize:   9,
      color:      colors.axisLabel,
      fontFamily: 'Roboto',
    );
    final axisNameStyle = TextStyle(
      fontSize:   10,
      color:      colors.axisLabel,
      fontFamily: 'Roboto',
    );

    return LineChartData(
      minX: minTemp,
      maxX: maxTemp,
      minY: range.min,
      maxY: range.max,
      clipData: const FlClipData.all(),

      // ── Grid ─────────────────────────────────────────────────────────────
      gridData: FlGridData(
        show: true,
        horizontalInterval: dInterval,
        verticalInterval:   tInterval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: colors.grid, strokeWidth: 0.5),
        getDrawingVerticalLine: (_) =>
            FlLine(color: colors.grid, strokeWidth: 0.5),
      ),

      // ── Axes ─────────────────────────────────────────────────────────────
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: Text('°C', style: axisNameStyle),
          sideTitles: SideTitles(
            showTitles: true,
            interval:     tInterval,
            reservedSize: 22,
            getTitlesWidget: (val, _) =>
                Text(val.toStringAsFixed(0), style: axisLabelStyle),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text('kg/l', style: axisNameStyle),
          sideTitles: SideTitles(
            showTitles: true,
            interval:     dInterval,
            reservedSize: 54,
            getTitlesWidget: (val, _) =>
                Text(val.toStringAsFixed(3),
                    style: axisLabelStyle.copyWith(fontSize: 8)),
          ),
        ),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      // ── Border ───────────────────────────────────────────────────────────
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 0.5),
          left:   BorderSide(color: colors.border, width: 0.5),
        ),
      ),

      // ── Tooltip ──────────────────────────────────────────────────────────
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor:     (_) => colors.tooltipBg,
          tooltipBorder:       BorderSide(color: colors.border, width: 0.5),
          tooltipRoundedRadius: AppRadii.sm,
          getTooltipItems: (spots) => spots.map((s) {
            return LineTooltipItem(
              '${s.x.toStringAsFixed(1)}°C\n'
              '${s.y.toStringAsFixed(4)} kg/l',
              TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w500,
                color:      colors.tooltipText,
                fontFamily: 'Roboto',
              ),
            );
          }).toList(),
        ),
      ),

      // ── Lines & points ───────────────────────────────────────────────────
      lineBarsData: [
        // 1. Паспортная кривая — синяя линия
        LineChartBarData(
          spots:            passportSpots,
          isCurved:         true,
          curveSmoothness:  0.3,
          color:            colors.curve,
          barWidth:         1.5,
          dotData:          const FlDotData(show: false),
          belowBarData: BarAreaData(
            show:  true,
            color: colors.curveFill,
          ),
        ),

        // 2. Пунктирная вертикаль на ОПЕРАЦИОННОЙ точке (синяя, движется)
        LineChartBarData(
          spots: [
            FlSpot(operatingPoint.tempC, range.min),
            FlSpot(operatingPoint.tempC, range.max),
          ],
          color:     colors.operatingDash,
          barWidth:  1,
          dotData:   const FlDotData(show: false),
          dashArray: [4, 4],
        ),

        // 3. 🔵 Операционная точка — синяя (density @ delivery temp)
        LineChartBarData(
          spots:    [FlSpot(operatingPoint.tempC, operatingPoint.densityKgL)],
          color:    colors.operating,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius:      6,
              color:       colors.operating,
              strokeColor: colors.surface,
              strokeWidth: 2,
            ),
          ),
        ),

        // 4. Пунктирная вертикаль на ПАСПОРТНОЙ точке (красная, t=15)
        LineChartBarData(
          spots: [
            FlSpot(referencePoint.tempC, range.min),
            FlSpot(referencePoint.tempC, range.max),
          ],
          color:     colors.referenceDash,
          barWidth:  1,
          dotData:   const FlDotData(show: false),
          dashArray: [3, 5],
        ),

        // 5. 🔴 Паспортная точка — красная (P15 @ 15°C, фиксирована)
        LineChartBarData(
          spots:    [FlSpot(referencePoint.tempC, referencePoint.densityKgL)],
          color:    colors.reference,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius:      5,
              color:       colors.reference,
              strokeColor: colors.surface,
              strokeWidth: 2,
            ),
          ),
        ),

        // 6. Точка смеси — зелёная (Phase 3)
        if (mixturePoint != null)
          LineChartBarData(
            spots:    [FlSpot(mixturePoint!.tempC, mixturePoint!.densityKgL)],
            color:    colors.mixture,
            barWidth: 0,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius:      5,
                color:       colors.mixture,
                strokeColor: colors.surface,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChartColors — isolated color set for light / dark.
// Single source of truth for all chart colors.
// ─────────────────────────────────────────────────────────────────────────────
class _ChartColors {
  final bool isDark;
  const _ChartColors(this.isDark);

  // Container
  Color get surface => isDark ? AppColorsDark.surface : AppColors.surface;
  Color get border  => isDark ? AppColorsDark.border  : AppColors.border;

  // Grid & axes
  Color get grid      => isDark ? AppColorsDark.chartGrid : AppColors.divider;
  Color get axisLabel => isDark ? AppColorsDark.textHint  : AppColors.textHint;

  // Tooltip
  Color get tooltipBg   => isDark ? AppColorsDark.surface      : AppColors.surface;
  Color get tooltipText => isDark ? AppColorsDark.textPrimary   : AppColors.textPrimary;

  // Passport curve (синяя линия)
  Color get curve     => isDark ? AppColorsDark.accent           : AppColors.accent;
  Color get curveFill => isDark ? AppColorsDark.chartFill        : AppColors.accent.withAlpha(15);

  // 🔵 Operating point (движется)
  Color get operating     => isDark ? AppColorsDark.chartOperating   : AppColors.accent;
  Color get operatingDash => isDark
      ? AppColorsDark.chartOperating.withAlpha(100)
      : AppColors.accent.withAlpha(80);

  // 🔴 Reference point P15 @ 15°C (фиксирован, одинаков в обоих темах)
  Color get reference     => AppColors.brand;
  Color get referenceDash => AppColors.brand.withAlpha(60);

  // Phase 3 mixture point
  Color get mixture => isDark ? AppColorsDark.success : AppColors.success;
}
