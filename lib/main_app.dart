import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stewart_platform_control/core/config/config.dart';
import 'package:stewart_platform_control/core/io/controller/mdbox_controller.dart';
import 'package:stewart_platform_control/presentation/platform_control/platform_control_page.dart';
///
class MainApp extends StatelessWidget {
  final RawDatagramSocket _chartsAppSocket;
  final Config _config;
  ///
  const MainApp({
    super.key,
    required Config config,
    required RawDatagramSocket chartsAppSocket,
    required SharedPreferences preferences,
  }) : 
    _config = config,
    _chartsAppSocket = chartsAppSocket;
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlatformControlPage(
        chartsAppSocket: _chartsAppSocket,
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
