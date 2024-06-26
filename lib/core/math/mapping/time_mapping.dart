import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stewart_platform_control/core/math/mapping/mapping.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
/// 
/// Computes [O] frequently based on how many seconds passed (with seconds fractions).
class TimeMapping<O> extends ValueNotifier<O> implements MinMaxedMapping<double,O> {
  final MinMaxedMapping<double,O> _mapping;
  final Duration _frequency;
  DateTime _startTime = DateTime.now();
  Timer? _timer;
  ///
  TimeMapping({
    required MinMaxedMapping<double, O> mapping,
    required Duration frequency,
  }) :
    _mapping = mapping,
    _frequency = frequency,
    super(mapping.of(0.0));
  ///
  void start() {
    stop();
    _startTime = DateTime.now();
    _timer = Timer.periodic(_frequency, (_) {
      final t =  DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
      value = of(t);
    });
  }
  ///
  void stop() {
    _timer?.cancel();
  }
  //
  @override
  O of(double x) => _mapping.of(x);
  //
  @override
 MinMax<O> get minMax => _mapping.minMax;
}