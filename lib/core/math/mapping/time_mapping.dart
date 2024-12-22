import 'package:flutter/foundation.dart';
import 'package:stewart_platform_control/core/math/mapping/mapping.dart';
/// 
/// Continuosly computes [value] based on time
abstract interface class TimeMapping<O> implements MinMaxedMapping<double,O>, ValueListenable<O> {
  /// 
  /// Starts computational process
  void start();
  /// 
  /// Stops computational process
  void stop();
}
