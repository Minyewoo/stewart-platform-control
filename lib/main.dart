import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stewart_platform_control/core/config/file_config.dart';
import 'package:stewart_platform_control/main_app.dart';
import 'package:window_manager/window_manager.dart';
//
Future<void> main() async {
  hierarchicalLoggingEnabled = true;
  const log = Log('main');
  _defineLogLevel(log);
  const fileConfig = FileConfig(
    file: TextFile.asset('assets/configs/app-config.json'),
  );
  const windowOptions = WindowOptions(
    title: 'Управление платформой Стюарта',
    minimumSize: Size(800, 600),
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.black,
    fullScreen: false,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow(
        windowOptions, 
        () async {
          await windowManager.show();
        },
      );
      final config = await fileConfig.read();
      final preferences = await SharedPreferences.getInstance();
      runApp(
        MainApp(
          config: config,
          preferences: preferences,
          chartsAppSocket: await RawDatagramSocket.bind(
            config.chartsAppHost,
            config.chartsAppPort,
          ),
        ),
      );
    },
    (error, stackTrace) => log.error(
      error.toString(),
      error,
      stackTrace,
    ),
  );
}
///
void _defineLogLevel(Log log) {
  const mode = (kReleaseMode, kProfileMode, kDebugMode);
  switch(mode) {
    case (true, false, false):
      log.level = LogLevel.off;
      break;
    case (false, true, false):
      log.level = LogLevel.info;
      break;
    case (false, false, true):
      log.level = LogLevel.debug;
      break;
    default:
      log.level = LogLevel.all;
      break;
  }
}