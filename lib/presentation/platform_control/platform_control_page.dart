import 'dart:async';
import 'dart:math';
import 'package:ditredi/ditredi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:hmi_core/hmi_core_app_settings.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:hmi_widgets/hmi_widgets.dart';
import 'package:stewart_platform_control/core/entities/cilinders_extractions_3f.dart';
import 'package:stewart_platform_control/core/io/excel_cilinders_mapping.dart';
import 'package:stewart_platform_control/core/io/excel_mapping.dart';
import 'package:stewart_platform_control/core/io/controller/mdbox_controller.dart';
import 'package:stewart_platform_control/core/math/mapping/fluctuation_lengths_mapping.dart';
import 'package:stewart_platform_control/core/math/mapping/frequent_time_mapping.dart';
import 'package:stewart_platform_control/core/math/mapping/time_mapping.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/math/sine.dart';
import 'package:stewart_platform_control/core/platform/platform_state.dart';
import 'package:stewart_platform_control/core/platform/stewart_platform.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_center/colored_coords.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_center/fluctuation_center_coords.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_center/fluctuation_side_projection.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_charts.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sines/min_max_notifier.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sines/platform_angle_sines.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sines/platform_control_app_bar.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sines/sine_notifier.dart';
///
class PlatformControlPage extends StatefulWidget {
  final double _cilinderMaxHeight;
  final Duration _controlFrequency;
  final Duration _reportFrequency;
  final double _realPlatformDimension;
  final MdboxController _controller;
  final DsClient _dsClient;
  ///
  const PlatformControlPage({
    super.key,
    required MdboxController controller,
    required double realPlatformDimension,
    required double cilinderMaxHeight,
    required DsClient dsClient,
    Duration controlFrequency = const Duration(milliseconds: 100),
    Duration reportFrequency = const Duration(milliseconds: 100),
  }) :
    _dsClient = dsClient,
    _realPlatformDimension = realPlatformDimension, 
    _controller = controller,
    _cilinderMaxHeight = cilinderMaxHeight,
    _controlFrequency = controlFrequency,
    _reportFrequency = reportFrequency;
  //
  @override
  State<PlatformControlPage> createState() => _PlatformControlPageState();
}
///
class _PlatformControlPageState extends State<PlatformControlPage> {
  late final SineNotifier _rotationAngleX;
  late final SineNotifier _rotationAngleY;
  late final SineNotifier _baseline;
  late final MinMaxNotifier _angleMinMaxNotifier;
  late final MinMaxNotifier _baselineMinMaxNotifier;
  late final ValueNotifier<Offset> _fluctuationCenterNotifier;
  late final StewartPlatform _platform;
  late final Stream<DsDataPoint<double>> _platformStateStream;
  final StreamController<String> _messagesController = StreamController<String>.broadcast();
  late bool _isPlatformMoving;
  late bool _isProjectionsHidden;
  //
  @override
  void initState() {
    _isPlatformMoving = false;
    _isProjectionsHidden = false;
    _fluctuationCenterNotifier = ValueNotifier(const Offset(0.0, 0.0));
    _rotationAngleX = SineNotifier(
      sine: const Sine(
        amplitude: 0.0,
        baseline: 0.0,
      ),
    );
    _rotationAngleY = SineNotifier(
      sine: const Sine(
        amplitude: 0.0,
        baseline: 0.0,
      ),
    );
    _baseline = SineNotifier(
      sine: const Sine(
        amplitude: 0.0,
        baseline: 0.0,
        alwaysGreaterThanZero: true,
      ),
    );
    final angleXMinMax = _rotationAngleX.value.minMax;
    final angleYMinMax = _rotationAngleY.value.minMax;
    _angleMinMaxNotifier = MinMaxNotifier(
      minMax: MinMax<double>(
        min: min(angleXMinMax.min, angleYMinMax.min),
        max: max(angleXMinMax.max, angleYMinMax.max),
      ),
    );
    _baselineMinMaxNotifier = MinMaxNotifier(
      minMax: MinMax(
        min: 0.0,
        max: widget._cilinderMaxHeight,
      ),
    );
    _rotationAngleX.addListener(() {
      final newMinMax = _rotationAngleX.value.minMax;
      final currentYMinMax = _rotationAngleY.value.minMax;
      _angleMinMaxNotifier.value = MinMax<double>(
        min: min(newMinMax.min, currentYMinMax.min),
        max: max(newMinMax.max, currentYMinMax.max),
      );
    });
     _rotationAngleY.addListener(() {
      final newYMinMax = _rotationAngleY.value.minMax;
      final currentXMinMax = _rotationAngleX.value.minMax;
      _angleMinMaxNotifier.value = MinMax<double>(
        min: min(newYMinMax.min, currentXMinMax.min),
        max: max(newYMinMax.max, currentXMinMax.max),
      );
    });
    _platform = StewartPlatform(
      controlFrequency: widget._controlFrequency,
      reportFrequency: widget._reportFrequency,
      controller: widget._controller,
      onStartControl: () {
        setState(() {
          _isPlatformMoving = true;
        });
      },
      onStopControl: () {
        setState(() {
          _isPlatformMoving = false;
        });
      },
      onStatusReport: (message) {
        _messagesController.add(message);
      },
    );
    _platformStateStream = _platform.state.transform<DsDataPoint<double>>(
      StreamTransformer.fromHandlers(
        handleData: (state, sink) {
          final now = DsTimeStamp.now().toString();
          final position = state.beamsPosition;
          final dataToAdd = [position.cilinder1, position.cilinder2, position.cilinder3];
          for(int i = 0; i<dataToAdd.length; i++) {
            sink.add(
              DsDataPoint<double>(
                type: DsDataType.integer,
                name: DsPointName('/cilinder$i'),
                value: dataToAdd[i]*1000,
                status: DsStatus.ok,
                timestamp: now,
                cot: DsCot.inf,
              ),
            );
          }
          sink.add(
            DsDataPoint<double>(
              type: DsDataType.integer,
              name: DsPointName('/phiX'),
              value: state.fluctuationAngles.dy.toDegrees(),
              status: DsStatus.ok,
              timestamp: now,
              cot: DsCot.inf,
            ),
          );
          sink.add(
            DsDataPoint<double>(
              type: DsDataType.integer,
              name: DsPointName('/phiY'),
              value: state.fluctuationAngles.dx.toDegrees(),
              status: DsStatus.ok,
              timestamp: now,
              cot: DsCot.inf,
            ),
          );
        },
      ),
    ).asBroadcastStream();
    super.initState();
  }
  //
  @override
  void dispose() {
    _rotationAngleX.dispose();
    _rotationAngleY.dispose();
    _baseline.dispose();
    _fluctuationCenterNotifier.dispose();
    _platform.dispose();
    _messagesController.close();
    super.dispose();
  }
  //
  @override
  Widget build(BuildContext context) {
    const horizontalRadius = cilindersPlacementRadius*sqrt3/2;
    final theme = Theme.of(context);
    const switchingDuration = Duration(milliseconds: 300);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: Setting('padding', factor: 3).toDouble),
        child: FloatingActionButton.small(
          tooltip: _isProjectionsHidden ? 'Показать проекции' : 'Скрыть проекции',
          onPressed: _toggleProjectionsVisibility,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Icon(
            _isProjectionsHidden
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          ),
        ),
      ),
      appBar: PlatformControlAppBar(
        messagesStream: _messagesController.stream,
        onSave: () {}, //_saveValues,
        onPlayFile: _onPlayFile,
        onPlayFileCilinders: _onPlayFileCilinders,
        onStartFluctuations:  _onStartFluctuations,
        onZeroPositionRequest: _onZeroPos,
        onMaxPositionRequest: _onMaxPos,
        onMinPositionRequest: _onMinPos,
        onPlatformStop: _platform.stop,
        isPlatformMoving: _isPlatformMoving,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: switchingDuration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: switch(_isPlatformMoving) {
                true => FluctuationCharts(
                  dsClient: widget._dsClient,
                  platformStateStream: _platformStateStream,
                ),
                false => PlatformAngleSines(
                  baselineMinMax: _baselineMinMaxNotifier,
                  anglesMinMax: _angleMinMaxNotifier,  
                  isDisabled: _isPlatformMoving,              
                  rotationAngleX: _rotationAngleX,
                  rotationAngleY: _rotationAngleY,
                  baseline: _baseline,
                ),
              },
            ),
          ),
          _isProjectionsHidden 
          ? const SizedBox()
          : Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTight = constraints.maxWidth < 250;
                        return Row(
                          children: [
                            if (!isTight)
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  ColoredCoords(
                                    xText: TextSpan(
                                      style: const TextStyle(color: Colors.redAccent),
                                      children: [
                                        const TextSpan(text: 'x'),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 4),
                                            child: const Text(
                                              'O',
                                              textScaler: TextScaler.linear(0.8),
                                              style: TextStyle(color: Colors.redAccent),
                                            ),
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 4),
                                            child: const Text(
                                              'y ',
                                              textScaler: TextScaler.linear(0.6),
                                              style: TextStyle(color: Colors.redAccent),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    yText: TextSpan(
                                      style: const TextStyle(color: Colors.blueAccent),
                                      children: [
                                        const TextSpan(text: 'y'),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 4),
                                            child: const Text(
                                              'O',
                                              textScaler: TextScaler.linear(0.8),
                                              style: TextStyle(color: Colors.blueAccent),
                                            ),
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 4),
                                            child: const Text(
                                              'x ',
                                              textScaler: TextScaler.linear(0.6),
                                              style: TextStyle(color: Colors.blueAccent),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(':'),
                                ],
                              ),
                            ),
                            // const Spacer(),
                            Expanded(
                              flex: 3,
                              child: FluctuationCenterCoords(
                                fluctuationCenter: _fluctuationCenterNotifier,
                              ),
                            ),
                            // const Spacer(),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _isPlatformMoving ? null : () {
                                      _fluctuationCenterNotifier.value = const Offset(0.0, 0.0);
                                    },
                                    icon: const Icon(Icons.cancel),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FluctuationSideProjection(
                        borderValues: const MinMax(
                          min: -horizontalRadius, 
                          max: horizontalRadius,
                        ),
                        isPlatformMoving: _isPlatformMoving,
                        type: RotationAxis.y,
                        realPlatformDimention: widget._realPlatformDimension,
                        fluctuationCenter: _fluctuationCenterNotifier,
                        platformState: _platform.state,
                        pointSize: 9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FluctuationSideProjection(
                        borderValues: const MinMax(
                          min: -cilindersPlacementRadius/2, 
                          max: cilindersPlacementRadius,
                        ),
                        isPlatformMoving: _isPlatformMoving,
                        type: RotationAxis.x,
                        realPlatformDimention: widget._realPlatformDimension,
                        fluctuationCenter: _fluctuationCenterNotifier,
                        platformState: _platform.state,
                        pointSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  ///
  Future<void> _fluctuateFromTimeMapping(TimeMapping<PlatformState> timeMapping) {
    setState(() {
      _isPlatformMoving = true;
    });
    return _platform.startFluctuations(
      timeMapping,
    );
  }
  ///
  Future<void> _fluctuateFromTimeMappingUnsafe(TimeMapping<PlatformState> timeMapping) {
    setState(() {
      _isPlatformMoving = true;
    });
    return _platform.startFluctuationsUnsafe(
      timeMapping,
    );
  }
  ///
  void _onStartFluctuations() {
    _fluctuateFromTimeMapping(_generateFluctuationFunction(applyHeightOffset: true),);
  }
  ///
  Future<void> _onPlayFile() async {
    final filePath = await _pickFile();
    return switch(filePath) {
      Some(:final value) => switch(await ExcelMapping(filePath: value).timeMapping()) {
        Some(:final value) => _fluctuateFromTimeMapping(value),
        None() => mounted ? BottomMessage.error(title: 'Неверные данные').show(context) : null,
      },
      None() => mounted ? BottomMessage.warning(title: 'Файл не выбран').show(context) : null,
    };
  }
  ///
  Future<void> _onPlayFileCilinders() async {
    final filePath = await _pickFile();
    return switch(filePath) {
      Some(:final value) => switch(await ExcelCilindersMapping(filePath: value).timeMapping()) {
        Some(:final value) => _fluctuateFromTimeMappingUnsafe(value),
        None() => mounted ? BottomMessage.error(title: 'Неверные данные').show(context) : null,
      },
      None() => mounted ? BottomMessage.warning(title: 'Файл не выбран').show(context) : null,
    };
  }
  ///
  Future<void> _onZeroPos() async {
    setState(() {
      _isPlatformMoving = true;
    });
    await _platform.setBeamsToZeroPositions();
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPlatformMoving = false;
      });
    });
  }
  ///
  Future<void> _onMaxPos() async {
    setState(() {
      _isPlatformMoving = true;
    });
    await _platform.setBeamsToMaxAmplitudePositions(
      _generateFluctuationFunction(applyHeightOffset: true),
    );
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPlatformMoving = false;
      });
    });
  }
  ///
  Future<void> _onMinPos() async {
    setState(() {
      _isPlatformMoving = true;
    });
    await _platform.setBeamsToMinAmplitudePositions(
      _generateFluctuationFunction(applyHeightOffset: true),
    );
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPlatformMoving = false;
      });
    });
  }
  ///
  TimeMapping<PlatformState> _generateFluctuationFunction({
    required bool applyHeightOffset,
  }) {
    final baselineSine =  _baseline.value;
    final fluctuationFunction = FluctuationLengthsFunction(
      fluctuationCenter: _fluctuationCenterNotifier.value,
      phiXSine: _rotationAngleX.value,
      phiYSine: _rotationAngleY.value,
      baselineSine: baselineSine,
    );
    final fluctuationMinPositions = fluctuationFunction.minMax.min.beamsPosition;
    final lowerPosition = [
      fluctuationMinPositions.cilinder1,
      fluctuationMinPositions.cilinder2,
      fluctuationMinPositions.cilinder3,
    ].reduce(min);
    final heightOffset = lowerPosition < 0 ? lowerPosition.abs() : 0.0;
    return FrequentTimeMapping(
      mapping: applyHeightOffset 
        ? fluctuationFunction.copyWith(
          baselineSine: baselineSine
            .copyWith(baseline: baselineSine.baseline + heightOffset),
        )
        : fluctuationFunction,
      frequency: const Duration(milliseconds: 50),
    );
  }
  ///
  Future<Option<String>> _pickFile() {
    return FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    ).then((result) async {
      if(result case FilePickerResult(:final xFiles)) {
        if(xFiles case [final file]) {
          return Some(file.path);
        }
      }
      return const None();
    });
  }
  ///
  void _toggleProjectionsVisibility() {
    setState(() {
      _isProjectionsHidden = !_isProjectionsHidden;
    });
  }
}
