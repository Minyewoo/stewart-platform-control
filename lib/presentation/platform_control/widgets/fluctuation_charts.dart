import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:hmi_widgets/hmi_widgets.dart';
import 'package:path/path.dart';
import 'package:stewart_platform_control/core/io/csv_data_point_logger.dart';
///
class FluctuationCharts extends StatefulWidget {
  final DsClient _dsClient;
  final Stream<DsDataPoint<double>> _platformStateStream;
  ///
  const FluctuationCharts({
    super.key,
    required Stream<DsDataPoint<double>> platformStateStream,
    required DsClient dsClient,
  }) :
    _dsClient = dsClient,
    _platformStateStream = platformStateStream;

  @override
  State<FluctuationCharts> createState() => _FluctuationChartsState();
}

class _FluctuationChartsState extends State<FluctuationCharts> {
  late final CsvDataPointLogger _pointLogger;
  //
  @override
  void initState() {
    final dsClient = widget._dsClient;
    _pointLogger = CsvDataPointLogger(
      pointsStreams: [
        widget._platformStateStream,
        dsClient.streamReal('Platform.Roll'),
        dsClient.streamReal('Platform.Pitch'),
        dsClient.streamReal('Platform.Yaw'),
        dsClient.streamReal('Platform.DeltaAngleX'),
        dsClient.streamReal('Platform.DeltaAngleY'),
        dsClient.streamReal('Platform.DeltaAngleZ'),
        dsClient.streamReal('Platform.Heave'),
        dsClient.streamReal('Platform.FluctuationPeriod'),
        dsClient.streamReal('Platform.VelocityZ'),
      ],
      directoryPath: join('run_logs', DateTime.now().toIso8601String()),
      converter: const ListToCsvConverter(
        fieldDelimiter: ';',
        eol: '\r\n',
      ),
    );
    super.initState();
  }
  //
  @override
  void dispose() {
    _pointLogger.dispose();
    super.dispose();
  }
  //
  @override
  Widget build(BuildContext context) {
    const liveAxisBufferLength = 12000;
    const xMarkInterval = Duration(seconds: 6);
    final xMarkIntervalMilliseconds = xMarkInterval.inMilliseconds.toDouble();
    final minX = DateTime.now().subtract(xMarkInterval)
      .millisecondsSinceEpoch.toDouble();
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    legendWidth: 220,
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'cilinder0',
                        caption: 'Задание цилиндра I, мм',
                        color: Colors.orangeAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'cilinder1',
                        caption: 'Задание цилиндра II, мм',
                        color: Colors.cyanAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'cilinder2',
                        caption: 'Задание цилиндра III, мм',
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    legendWidth: 270,
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'phiX',
                        caption: 'Задание угла вокруг Y, град',
                        color: Colors.redAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'phiY',
                        caption: 'Задание угла вокруг X, град',
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    legendWidth: 260,
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Roll'),
                        signalName: 'Platform.Roll',
                        caption: 'Угол крена (roll), град',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Pitch'),
                        signalName: 'Platform.Pitch',
                        caption: 'Угол тангажа (pitch), град',
                        color: Colors.greenAccent,
                      ),
                      // LiveAxis(
                      //   bufferLength: liveAxisBufferLength,
                      //   stream: _dsClient.streamReal('Platform.Yaw'),
                      //   signalName: 'Platform.Yaw',
                      //   caption: 'Угол рыскания (yaw), град',
                      //   color: Colors.orangeAccent,
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    legendWidth: 280,
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.DeltaAngleX'),
                        signalName: 'Platform.DeltaAngleX',
                        caption: 'Угловая скорость X, град/с - 1',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.DeltaAngleY'),
                        signalName: 'Platform.DeltaAngleY',
                        caption: 'Угловая скорость Y, град/с - 1',
                        color: Colors.greenAccent,
                      ),
                      // LiveAxis(
                      //   bufferLength: liveAxisBufferLength,
                      //   stream: _dsClient.streamReal('Platform.DeltaAngleZ'),
                      //   signalName: 'Platform.DeltaAngleZ',
                      //   caption: 'Угловая скорость Z, градусы/с - 1',
                      //   color: Colors.orangeAccent,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Heave'),
                        signalName: 'Platform.Heave',
                        caption: 'Heave, м',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.FluctuationPeriod'),
                        signalName: 'Platform.FluctuationPeriod',
                        caption: 'Период качки, с',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    minX: minX,
                    xInterval: xMarkIntervalMilliseconds,
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.VelocityZ'),
                        signalName: 'Platform.VelocityZ',
                        caption: 'Скорость по Z, м/с',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}