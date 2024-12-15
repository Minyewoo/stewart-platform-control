import 'package:flutter/material.dart';
import 'package:hmi_networking/hmi_networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stewart_platform_control/core/config/config.dart';
import 'package:stewart_platform_control/core/io/controller/mdbox_controller.dart';
import 'package:stewart_platform_control/presentation/platform_control/platform_control_page.dart';
///
class MainApp extends StatelessWidget {
  final Config _config;
  final DsClient _dsClient;
  ///
  const MainApp({
    super.key,
    required Config config,
    required SharedPreferences preferences,
    required DsClient dsClient,
  }) :
    _dsClient = dsClient, 
    _config = config;
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlatformControlPage(
        dsClient: _dsClient,
        cilinderMaxHeight: _config.cilinderMaxHeight,
        controlFrequency: _config.controlFrequency,
        controller: MdboxController(
          myAddress: _config.myAddress,
          controllerAddress:  _config.controllerAddress,
        ),
        realPlatformDimension: 0.8,
      ),
      theme: ThemeData.dark(),
    );
  }
}
