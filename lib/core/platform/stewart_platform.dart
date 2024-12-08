import 'dart:async';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:stewart_platform_control/core/entities/cilinder_lengths_3f.dart';
import 'package:stewart_platform_control/core/io/controller/mdbox_controller.dart';
import 'package:stewart_platform_control/core/math/mapping/time_mapping.dart';
import 'package:stewart_platform_control/core/platform/platform_state.dart';
///
class StewartPlatform {
  final RawDatagramSocket _chartsAppSocket;
  final MdboxController _controller;
  final void Function()? _onStartControl;
  final void Function()? _onStopControl;
  final void Function(String)? _onStatusReport;
  final _stateController = StreamController<PlatformState>.broadcast();
  TimeMapping<PlatformState>? _continousPosition;
  bool _isStopped = false; 
  ///
  StewartPlatform({
    required Duration controlFrequency,
    required Duration reportFrequency,
    required MdboxController controller,
    required RawDatagramSocket chartsAppSocket,
    void Function()? onStartControl,
    void Function()? onStopControl,
    void Function(String message)? onStatusReport,
  }) :
    _controller = controller,
    _onStatusReport = onStatusReport,
    _onStartControl = onStartControl,
    _onStopControl = onStopControl,
    _chartsAppSocket = chartsAppSocket;
  ///
  Stream<PlatformState> get state => _stateController.stream;
  ///
  Future<void> startFluctuations(TimeMapping<PlatformState> continousPosition) async {
    _continousPosition?.stop();
    _continousPosition = continousPosition;
    final starterPosition = _continousPosition!.of(0);
    _isStopped = false;
    await _sendFluctuationStarterPositions(
      starterPosition.beamsPosition,
      starterPosition.fluctuationAngles,
    );
    if(!_isStopped) {
      _onStatusReport?.call('Начало колебаний');
      _continousPosition!.start();
      _continousPosition!.addListener(() {
        final platformState = _continousPosition!.value;
        _updatePlatformState(platformState);
        final package = ByteData(16)
        ..setFloat64(0, platformState.beamsPosition.cilinder1)
        ..setInt64(8, DateTime.now().millisecondsSinceEpoch);
        _chartsAppSocket.send(
          package.buffer.asUint8List(),
          InternetAddress.loopbackIPv4, 4756,
        );
      });
      _onStartControl?.call();
    }
  }
  ///
  Future<void> setBeamsToZeroPositions({Duration time = const Duration(seconds: 10)}) async {
    _isStopped = false;
    await _sendZeroPosition(time: time);
    _isStopped = true;
  }
  ///
  Future<void> setBeamsToMaxAmplitudePositions(
    TimeMapping<PlatformState> mapping, {
    Duration time = const Duration(seconds: 10),
  }) async {
    _isStopped = false;
    const rampTimeForMeter = Duration(seconds: 10);
    await _sendZeroPosition(time: rampTimeForMeter);
    if(!_isStopped) {
      _onStatusReport?.call('Переход в максимальную позицию колебания');
      _updatePlatformState(
        mapping.minMax.max,
        time: time,
      );
    }
    _isStopped = true;
  }
  ///
  Future<void> setBeamsToMinAmplitudePositions(
    TimeMapping<PlatformState> mapping, {
    Duration time = const Duration(seconds: 10),
  }) async {
    _isStopped = false;
    const rampTimeForMeter = Duration(seconds: 10);
    await _sendZeroPosition(time: rampTimeForMeter);
    if(!_isStopped) {
      _onStatusReport?.call('Переход в минимальную позицию колебания');
      _updatePlatformState(
        mapping.minMax.min,
        time: time,
      );
    }
    _isStopped = true;
  }
  ///
  Future<void> _sendZeroPosition({Duration time = const Duration(seconds: 10)}) async {
    if(!_isStopped) {
      final initialPositioningtime = Duration(milliseconds: time.inMilliseconds);
      const zeroPosition = CilinderLengths3f();
      _onStatusReport?.call('Переход в нулевую позицию');
      _updatePlatformState(
        const PlatformState(
          beamsPosition: zeroPosition,
          fluctuationAngles: Offset(0,0),
        ),
        time: initialPositioningtime,
      );
      await Future.delayed(initialPositioningtime);
    }
  }
  ///
  Future<void> _sendFluctuationStarterPositions(CilinderLengths3f lengths, Offset angles) async {
    const rampTimeForMeter = Duration(seconds: 10);
    await _sendZeroPosition(time: rampTimeForMeter);
    if(!_isStopped) {
      final actualRampTime = Duration(
        milliseconds: (
          [lengths.cilinder1, lengths.cilinder2, lengths.cilinder3]
            .reduce(max) * rampTimeForMeter.inMilliseconds
        ).round(),
      );
      _onStatusReport?.call('Переход в начальную позицию колебаний');
      _updatePlatformState(
        PlatformState(
          beamsPosition: lengths,
          fluctuationAngles: angles,
        ),
        time: rampTimeForMeter,
      );
      await Future.delayed(actualRampTime);
    }
  }
  ///
  void _updatePlatformState(PlatformState state, {
    Duration time = const Duration(milliseconds: 50),
  }) {
    if(!_isStopped) {
      _controller.sendPosition3i(
        state.beamsPosition,
        time: time,
      );
      _stateController.add(state);
    }
  }
  ///
  void stop() {
    _onStatusReport?.call('Колебания прерваны');
    _isStopped = true;
    _continousPosition?.stop();
    _onStopControl?.call();
  }
  ///
  void dispose() {
    stop();
    _stateController.close();
  }
}