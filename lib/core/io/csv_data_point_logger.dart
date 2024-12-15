import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:path/path.dart';
///
class CsvDataPointLogger {
  final String _directoryPath;
  final ListToCsvConverter _converter;
  late final List<StreamSubscription<DsDataPoint>> _dataPointSubscriptions;
  final Map<String,IOSink> _logFiles = {};
  late final int _startTimestamp;
  ///
  CsvDataPointLogger({
    required List<Stream<DsDataPoint>> pointsStreams,
    ListToCsvConverter converter = const ListToCsvConverter(),
    String directoryPath = 'run_logs',
  }) :
    _converter = converter,
    _directoryPath = directoryPath {
      _startTimestamp = DateTime.now().millisecondsSinceEpoch;
      _dataPointSubscriptions = pointsStreams
        .map((stream) => stream.listen(_logDataPoint))
        .toList();
  }
  ///
  Future<void> _logDataPoint(DsDataPoint point) async {
    final pointName = point.name.name;
    if(!_logFiles.containsKey(pointName)) {
      final file = await File(join(_directoryPath, '$pointName.csv')).create(recursive: true);
      final ioSink = file.openWrite();
      ioSink.write('Time, ms${_converter.fieldDelimiter}Value${_converter.eol}');
      _logFiles[pointName] = ioSink;
    }
    final pointTimestamp = DateTime.tryParse(point.timestamp)?.millisecondsSinceEpoch ?? _startTimestamp;
    _logFiles[pointName]!.write(
      _converter.convert(
        [<dynamic>[pointTimestamp - _startTimestamp, point.value], null],
      ),
    );
  }
  ///
  Future<void> dispose() async {
    for(final subsctiption in _dataPointSubscriptions) {
      await subsctiption.cancel();
    }
    _dataPointSubscriptions.clear();
    for(final logFile in _logFiles.values) {
      await logFile.flush();
      await logFile.close();
    }
    _logFiles.clear();
  }
}