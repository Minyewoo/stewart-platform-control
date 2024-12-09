import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:hmi_widgets/hmi_widgets.dart';
///
class FluctuationCharts extends StatelessWidget {
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
                        stream: _platformStateStream,
                        signalName: 'cilinder0',
                        caption: 'Задание цилиндра I, мм',
                        color: Colors.orangeAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _platformStateStream,
                        signalName: 'cilinder1',
                        caption: 'Задание цилиндра II, мм',
                        color: Colors.cyanAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _platformStateStream,
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
                        stream: _platformStateStream,
                        signalName: 'alphaX',
                        caption: 'Задание угла вокруг Y, градусы',
                        color: Colors.redAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _platformStateStream,
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
                        stream: _dsClient.streamReal('Platform.Roll'),
                        signalName: 'Platform.Roll',
                        caption: 'Угол крена (roll), градусы',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _dsClient.streamReal('Platform.Pitch'),
                        signalName: 'Platform.Pitch',
                        caption: 'Угол тангажа (pitch), градусы',
                        color: Colors.greenAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _dsClient.streamReal('Platform.Yaw'),
                        signalName: 'Platform.Yaw',
                        caption: 'Угол рыскания (yaw), градусы',
                        color: Colors.orangeAccent,
                      ),
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
                        stream: _dsClient.streamReal('Platform.DeltaAngleX'),
                        signalName: 'Platform.DeltaAngleX',
                        caption: 'Угловая скорость X, градусы/с - 1',
                        color: Colors.purpleAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _dsClient.streamReal('Platform.DeltaAngleY'),
                        signalName: 'Platform.DeltaAngleY',
                        caption: 'Угловая скорость Y, градусы/с - 1',
                        color: Colors.greenAccent,
                      ),
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _dsClient.streamReal('Platform.DeltaAngleZ'),
                        signalName: 'Platform.DeltaAngleZ',
                        caption: 'Угловая скорость Z, градусы/с - 1',
                        color: Colors.orangeAccent,
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
                    minX: DateTime.now().subtract(xMarkInterval)
                      .millisecondsSinceEpoch.toDouble(),
                    xInterval: xMarkInterval.inMilliseconds.toDouble(),
                    axes: [
                      LiveAxis(
                        bufferLength: liveAxisBufferLength,
                        stream: _dsClient.streamReal('Platform.Heave'),
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