import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stewart_platform_control/core/math/mapping/time_mapping.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
///
class AbsoluteTimeValue<T> {
  final Duration absoluteDuration;
  final T value;
  ///
  const AbsoluteTimeValue({
    required this.absoluteDuration,
    required this.value,
  });
  AbsoluteTimeValue<O> map<O>(O Function(T) mappingFunction) {
    return AbsoluteTimeValue(
      absoluteDuration: absoluteDuration,
      value: mappingFunction(value),
    );
  }
}
///
class AbsoluteTimeMapping<O, T> extends ValueNotifier<O> implements TimeMapping<O> {
  final MinMax<O> _minMax;
  final List<AbsoluteTimeValue<O>> _absoluteValues;
  // DateTime _startTime = DateTime.now();
  final List<Timer> _timers = [];
  ///
  AbsoluteTimeMapping(super.value, {
    required MinMax<O> minMax,
    required List<AbsoluteTimeValue<O>> absoluteValues,
  }) :
    _minMax = minMax,
    _absoluteValues = absoluteValues;
  //
  @override
  MinMax<O> get minMax => _minMax;
  //
  @override
  O of(double x) {
    var index = 0;
    while(index < _absoluteValues.length - 1) {
      var range = (
        _absoluteValues[index].absoluteDuration.inMilliseconds,
        _absoluteValues[index+1].absoluteDuration.inMilliseconds,
      );
      if(x >= range.$1 && x*1000 < range.$2) {
        return _absoluteValues[index].value;
      }
      index += 1;
    }
    return _absoluteValues.last.value;
  }
  //
  @override
  void start() {
    stop();
    // _startTime = DateTime.now();
    _timers.addAll(
      _absoluteValues.map(
        (target) => Timer(
          target.absoluteDuration, () {
            value = target.value;
          },
        ),
      ),
    );
  }
  //
  @override
  void stop() {
    for(final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
  ///
  // void _maybeComputeValue(int index) {
  //   value = _absoluteTargets[index].value;
  //   if(index >= _absoluteTargets.length - 1) {
  //     return stop();
  //   }
  //   final nextIndex = index+1;
  //   final targetTime = _startTime.add(_absoluteTargets[nextIndex].absoluteDuration);
  //   _timer = Timer(targetTime.difference(DateTime.now()), () => _maybeComputeValue(nextIndex));
  // }
}