import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:hmi_widgets/hmi_widgets.dart';
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
  late final File _cilinder0Log;
  late final File _cilinder1Log;
  late final File _cilinder2Log;
  late final File _phiXLog;
  late final File _phiYLog;
  late final File _rollLog;
  late final File _pitchLog;
  late final File _yawLog;
  late final File _deltaAngleXLog;
  late final File _deltaAngleYLog;
  late final File _deltaAngleZLog;
  late final File _heaveLog;

  @override
  void initState() {
    const csvFieldDelimiter = ';';
    const csvEndOfLine = '\r\n';
    final isoNow = DateTime.now().toIso8601String();
    final pointToCsvTransformer = StreamTransformer<DsDataPoint<double>, String>.fromBind(
      (stream) => stream.map(
        (point) => <dynamic>[point.timestamp, point.value],
      ).transform(ListToCsvConverter(
        fieldDelimiter: csvFieldDelimiter,
        eol: csvEndOfLine,
      )),
    );
    //
    _cilinder0Log = File('Cilinder0_$isoNow.csv');
    _cilinder0Log.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._platformStateStream
      .where((point) => point.name.name == 'cilinder0')
      .transform(pointToCsvTransformer)
      .listen((row) => _cilinder0Log.writeAsString(row, mode: FileMode.append));
    //
    _cilinder1Log = File('Cilinder1_$isoNow.csv');
    _cilinder1Log.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._platformStateStream
      .where((point) => point.name.name == 'cilinder1')
      .transform(pointToCsvTransformer)
      .listen((row) => _cilinder1Log.writeAsString(row, mode: FileMode.append));
    //
    _cilinder2Log = File('Cilinder2_$isoNow.csv');
    _cilinder2Log.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._platformStateStream
      .where((point) => point.name.name == 'cilinder2')
      .transform(pointToCsvTransformer)
      .listen((row) => _cilinder2Log.writeAsString(row, mode: FileMode.append));
    //
    _phiXLog = File('PhiX_$isoNow.csv');
    _phiXLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._platformStateStream
      .where((point) => point.name.name == 'alphaX')
      .transform(pointToCsvTransformer)
      .listen((row) => _phiXLog.writeAsString(row, mode: FileMode.append));
    //
    _phiYLog = File('PhiY_$isoNow.csv');
    _phiYLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._platformStateStream
      .where((point) => point.name.name == 'alphaY')
      .transform(pointToCsvTransformer)
      .listen((row) => _phiYLog.writeAsString(row, mode: FileMode.append));
    //
    _rollLog = File('Roll_$isoNow.csv');
    _rollLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.Roll')
      .transform(pointToCsvTransformer)
      .listen((row) => _rollLog.writeAsString(row, mode: FileMode.append));
    //
    _pitchLog = File('Pitch_$isoNow.csv');
    _pitchLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.Pitch')
      .transform(pointToCsvTransformer)
      .listen((row) => _pitchLog.writeAsString(row, mode: FileMode.append));
    //
    _yawLog = File('Yaw_$isoNow.csv');
    _yawLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.Yaw')
      .transform(pointToCsvTransformer)
      .listen((row) => _yawLog.writeAsString(row, mode: FileMode.append));
    //
    _deltaAngleXLog = File('DeltaAngleX_$isoNow.csv');
    _deltaAngleXLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.DeltaAngleX')
      .transform(pointToCsvTransformer)
      .listen((row) => _deltaAngleXLog.writeAsString(row, mode: FileMode.append));
    //
    _deltaAngleYLog = File('DeltaAngleY_$isoNow.csv');
    _deltaAngleYLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.DeltaAngleY')
      .transform(pointToCsvTransformer)
      .listen((row) => _deltaAngleYLog.writeAsString(row, mode: FileMode.append));
    //
    _deltaAngleZLog = File('DeltaAngleZ_$isoNow.csv');
    _deltaAngleZLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.DeltaAngleZ')
      .transform(pointToCsvTransformer)
      .listen((row) => _deltaAngleZLog.writeAsString(row, mode: FileMode.append));
    //
    _heaveLog = File('Heave_$isoNow.csv');
    _heaveLog.writeAsString('Timestamp${csvFieldDelimiter}Value$csvEndOfLine', mode: FileMode.append);
    widget._dsClient.streamReal('Platform.DeltaAngleZ')
      .transform(pointToCsvTransformer)
      .listen((row) => _heaveLog.writeAsString(row, mode: FileMode.append));

    super.initState();
  }
  //
  @override
  void dispose() {
    _cilinder0Log.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _cilinder1Log.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _cilinder2Log.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _phiXLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _phiYLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _rollLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _pitchLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _yawLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _deltaAngleXLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _deltaAngleYLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _deltaAngleZLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    _heaveLog.writeAsString('\r\n', mode: FileMode.append, flush: true);
    super.dispose();
  }
  //
  @override
  Widget build(BuildContext context) {
    const liveAxisBufferLength = 12000;
    const xMarkInterval = Duration(seconds: 6);
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: LiveChartWidget(
                    legendWidth: 220,
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
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
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'alphaX',
                        caption: 'Задание угла вокруг Y, градусы',
                        color: Colors.redAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._platformStateStream,
                        signalName: 'alphaY',
                        caption: 'Задание угла вокруг X, градусы',
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
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Roll'),
                        signalName: 'Platform.Roll',
                        caption: 'Угол крена (roll), градусы',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Pitch'),
                        signalName: 'Platform.Pitch',
                        caption: 'Угол тангажа (pitch), градусы',
                        color: Colors.greenAccent,
                      ),
                      // LiveAxis(
                      //   bufferLength: liveAxisBufferLength,
                      //   stream: _dsClient.streamReal('Platform.Yaw'),
                      //   signalName: 'Platform.Yaw',
                      //   caption: 'Угол рыскания (yaw), градусы',
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
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.DeltaAngleX'),
                        signalName: 'Platform.DeltaAngleX',
                        caption: 'Угловая скорость X, градусы/с - 1',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.DeltaAngleY'),
                        signalName: 'Platform.DeltaAngleY',
                        caption: 'Угловая скорость Y, градусы/с - 1',
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
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: widget._dsClient.streamReal('Platform.Heave'),
                        signalName: 'Platform.Heave',
                        caption: 'Heave, метры',
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