import 'package:hmi_core/hmi_core.dart';
///
class DebugStreamEvents {
  final Stream<DsDataPoint<dynamic>> _stream;
  final LogLevel _logLevel;
  ///
  DebugStreamEvents({
    required Stream<DsDataPoint<dynamic>> stream,
    LogLevel logLevel = LogLevel.warning,
  }) :
    assert(
      logLevel == LogLevel.debug 
      || logLevel == LogLevel.config 
      || logLevel == LogLevel.info 
      || logLevel == LogLevel.warning 
      || logLevel == LogLevel.error
      || logLevel == LogLevel.off
    ),
    _stream = stream,
    _logLevel = logLevel;
  ///
  void run() {
    if (_logLevel == LogLevel.debug) {
      _stream.listen((event) {
        const Log('TagDebug').debug('event: $event');
      });        
    }
    // if (_logLevel == LogLevel.config) {
    //   _stream.listen((event) {
    //     const Log('TagDebug').config('event: $event');
    //   });        
    // }
    if (_logLevel == LogLevel.info) {
      _stream.listen((event) {
        const Log('TagDebug').info('event: $event');
      });        
    }
    if (_logLevel == LogLevel.warning) {
      _stream.listen((event) {
        const Log('TagDebug').warning('event: $event');
      });        
    }
    if (_logLevel == LogLevel.error) {
      _stream.listen((event) {
        const Log('TagDebug').error('event: $event');
      });        
    }
  }
}