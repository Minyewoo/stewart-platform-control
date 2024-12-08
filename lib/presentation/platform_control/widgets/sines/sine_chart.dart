import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/math/sine.dart';
///
class SineChart extends StatelessWidget {
  final Color? _sineColor;
  final double _factor;
  final int _periodWindow;
  final int _pointsCountFactor;
  final ValueNotifier<Sine> _sineNotifier;
  final ValueNotifier<MinMax>? _minMaxNotifier;
  ///
  const SineChart({
    super.key,
    required ValueNotifier<Sine> sineNotifier,
    Color? sineColor,
    ValueNotifier<MinMax>? minMaxNotifier,
    int periodWindow = 60,
    int pointsCountFactor = 10,
    double factor = 1.0,
  }) :
    _sineColor = sineColor,
    _pointsCountFactor = pointsCountFactor, 
    _periodWindow = periodWindow, 
    _sineNotifier = sineNotifier,
    _minMaxNotifier = minMaxNotifier,
    _factor = factor;
  //
  @override
  Widget build(BuildContext context) {
    return _minMaxNotifier == null
      ? ValueListenableBuilder(
          valueListenable: _sineNotifier,
          builder: (context, sine, child) => LineChart(
            _generateChartData(context, sine),
          ),
        )
      : ValueListenableBuilder(
          valueListenable: _minMaxNotifier,
          builder: (context, minMax, child) => ValueListenableBuilder(
            valueListenable: _sineNotifier,
            builder: (context, sine, child) => LineChart(
              _generateChartData(
                context,
                sine,
                minY: minMax.min*_factor,
                maxY: minMax.max*_factor,
              ),
            ),
          ),
        );
  }
  ///
  LineChartData _generateChartData(
    BuildContext context,
    Sine sine, {
      double? minY,
      double? maxY,
    }) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      lineBarsData: _generateSineSpots(sine),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
  ///
  List<LineChartBarData> _generateSineSpots(Sine sine) {
    return [
      LineChartBarData(
        color: _sineColor,
        barWidth: 2.0,
        dotData: const FlDotData(show: false),
        isCurved: true,
        spots: List.generate(
          _periodWindow * _pointsCountFactor,
          (t) => FlSpot(t / _pointsCountFactor, sine.of(t/_pointsCountFactor)*_factor),
        )
      ),
    ];
  }
}