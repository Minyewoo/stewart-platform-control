import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/math/sine.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/parameter_slider.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sine_chart.dart';
///
class SineControlWidget extends StatelessWidget {
  final String _title;
  final ValueNotifier<Sine> _sineNotifier;
  final ValueNotifier<MinMax> _minMaxNotifier;
  ///
  const SineControlWidget({
    super.key, 
    required ValueNotifier<Sine> sineNotifier,
    required ValueNotifier<MinMax> minMaxNotifier, 
    String title = '',
  }) : 
    _title = title,
    _sineNotifier = sineNotifier,
    _minMaxNotifier = minMaxNotifier;
  //
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if(_title.isNotEmpty)
              ...[
                const SizedBox(width: 16),
                Text(
                  _title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ParameterSlider(
                      label: 'Амплитуда',
                      valueNotifier: _sineNotifier,
                      minMax: const MinMax(min: 0, max: 1000),
                      divisions: 1000,
                      sliderValueBuilder: (sine) => sine.amplitude,
                      displayValueBuilder: (sine) => sine.amplitude.toStringAsFixed(0),
                      valueUnit: ' мм',
                      onChanged: _changeAmplitude,
                    ),
                  ),
                  Expanded(
                    child: ParameterSlider(
                      label: 'Период',
                      valueNotifier: _sineNotifier,
                      minMax: const MinMax(min: 0.1, max: 120),
                      divisions: 1199,
                      sliderValueBuilder: (sine) => sine.period,
                      displayValueBuilder: (sine) => sine.period.toStringAsFixed(1),
                      valueUnit: ' с',
                      onChanged: _changePeriod,
                    ),
                  ),
                  Expanded(
                    child: ParameterSlider(
                      label: 'Сдвиг фазы',
                      valueNotifier: _sineNotifier,
                      minMax: const MinMax(min: 0, max: 180),
                      divisions: 180,
                      sliderValueBuilder: (sine) => double.parse((sine.phaseShift*180/pi).toStringAsFixed(0)),
                      displayValueBuilder: (sine) => (sine.phaseShift*180/pi).toStringAsFixed(0),
                      valueUnit: '°',
                      onChanged: _changePhaseShift,
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _sineNotifier,
                      builder: (context, sine, child) => ParameterSlider(
                        label: 'Базовое значение',
                        valueNotifier: _sineNotifier,
                        minMax: MinMax(min: _sineNotifier.value.amplitude, max: 3000-_sineNotifier.value.amplitude),
                        divisions: (3000-_sineNotifier.value.amplitude*2).round(),
                        sliderValueBuilder: (sine) => sine.baseline,
                        displayValueBuilder: (sine) => sine.baseline.toStringAsFixed(0),
                        valueUnit: ' мм',
                        onChanged: _changeBaseline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: SineChart(
            sineNotifier: _sineNotifier,
            minMaxNotifier: _minMaxNotifier,
            periodWindow: 120,
            pointsCountFactor: 30,
          ),
        ),
      ],
    );
  }
  //
  void _changeAmplitude(double value) {
    _sineNotifier.value = _sineNotifier.value.copyWith(
      amplitude: value,
    );
  }
  //
  void _changeBaseline(double value) {
    _sineNotifier.value = _sineNotifier.value.copyWith(
      baseline: value,
    );
  }
  //
  void _changePeriod(double value) {
    _sineNotifier.value = _sineNotifier.value.copyWith(
      period: double.parse(value.toStringAsFixed(1)),
    );
  }
  //
  void _changePhaseShift(double value) {
    _sineNotifier.value = _sineNotifier.value.copyWith(
      phaseShift: _degreesToRadians(value),
    );
  }
  //
  double _degreesToRadians(double degrees) => degrees*pi/180;
}