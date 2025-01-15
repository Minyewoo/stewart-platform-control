import 'dart:async';
import 'package:flutter/material.dart' hide Localizations;
import 'package:hmi_core/hmi_core.dart';
import 'package:hmi_core/hmi_core_app_settings.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stewart_platform_control/core/config/file_config.dart';
import 'package:stewart_platform_control/debug_stream_events.dart';
import 'package:stewart_platform_control/exit_listening_widget.dart';
import 'package:stewart_platform_control/main_app.dart';
import 'package:window_manager/window_manager.dart';
//
Future<void> main() async {
  hierarchicalLoggingEnabled = true;
  const log = Log('main');
  _defineLogLevel(log);
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
  final (fileCache, memoryCache, cache) = await _initCaches();
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow(
        windowOptions, 
        () async {
          await windowManager.show();
        },
      );
      await _initStatics();
      const fileConfig = FileConfig(
        file: TextFile.asset('assets/configs/app-config.json'),
      );
      final config = await fileConfig.read();
      final preferences = await SharedPreferences.getInstance();
      final dsClient = _initDsClient(
        cache, 
        debugEvents: [
          'Local.System.Connection',
          'Connection',
        ],
      );
      final reconnectStartup = _initJds(dsClient)..run();
      runApp(
        ExitListeningWidget(
          onExit: () => _onExit(log, reconnectStartup, dsClient, fileCache, memoryCache),
          child: MainApp(
            config: config,
            preferences: preferences,
            dsClient: dsClient,
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
Future<void> _initStatics() async {
  await Localizations.initialize(
    AppLang.ru,
    jsonMap: JsonMap.fromTextFile(
      const TextFile.asset(
        'assets/translations/translations.json',
      ),
    ),
  );
  await AppSettings.initialize(
    jsonMap: JsonMap.fromTextFile(
      const TextFile.asset(
        'assets/settings/app-settings.json',
      ),
    ),
  );
}
///
void _defineLogLevel(Log log) {
  log.level = LogLevel.all;
  // const mode = (kReleaseMode, kProfileMode, kDebugMode);
  // switch(mode) {
  //   case (true, false, false):
  //     log.level = LogLevel.off;
  //     break;
  //   case (false, true, false):
  //     log.level = LogLevel.info;
  //     break;
  //   case (false, false, true):
  //     log.level = LogLevel.debug;
  //     break;
  //   default:
  //     log.level = LogLevel.all;
  //     break;
  // }
}
///
Future<(DsClientFileCache, DsClientMemoryCache, DsClientFilteredCache)> _initCaches() async {
  const fileCache = DsClientFileCache(
    cacheFile: DsCacheFile(
      TextFile.path('cache.json'),
    ),
  );
  final memoryCache = DsClientMemoryCache(
    initialCache: {
      for (final point in await fileCache.getAll()) 
        point.name.name: point,
    },
  );
  final filteredCache = DsClientFilteredCache(
    filter: (point) => point.cot == DsCot.inf, 
    cache: DsClientDelayedCache(
      primaryCache: memoryCache,
      secondaryCache: fileCache,
    ),
  );
  return (fileCache, memoryCache, filteredCache);
}
///
DsClientReal _initDsClient(DsClientCache cache, {List<String> debugEvents = const []}) {
  final dsClient = DsClientReal(
    line: JdsLine(
      lineSocket: DsLineSocket(
        ip: const Setting('jds-host').toString(), 
        port: const Setting('jds-port').toInt,
      ),
    ),
    cache: cache,
  );
  DebugStreamEvents(
    stream: dsClient.streamMerged(debugEvents),
  ).run();
  return dsClient;
}
///
JdsServiceStartupOnReconnect _initJds(DsClient dsClient) {
  final jdsService = JdsService(
    dsClient: dsClient,
    route: const JdsServiceRoute(
      appName: Setting('jds-app-name'),
      serviceName: Setting('jds-service-name'),
    ),
  );
  return JdsServiceStartupOnReconnect(
    connectionStatuses: dsClient.streamInt('Local.System.Connection'),
    startup: JdsServiceStartup(
      service: jdsService,
    ),
    isConnected: dsClient.isConnected(),
  );
}
///
Future<void> _onExit(
  Log log,
  JdsServiceStartupOnReconnect startup,
  DsClientReal dsClient,
  DsClientFileCache fileCache,
  DsClientMemoryCache memoryCache,
) async {
  log.info('Stopping server connection listening...');
  await startup.dispose();
  log.info('Stopping DsClient...');
  await dsClient.cancel();
  log.info('Persisting cache...');
  await fileCache.addMany(await memoryCache.getAll());
  log.info('Ready to exit!');
}
