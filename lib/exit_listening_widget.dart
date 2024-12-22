import 'dart:ui';
import 'package:flutter/material.dart';
/// 
/// Widget to perform actions before closing the app.
class ExitListeningWidget extends StatefulWidget {
  final Future<void> Function() _onExit;
  final Widget child;
  ///
  /// Widget to perform [onExit] actions before closing the app.
  const ExitListeningWidget({
    super.key,
    required Future<void> Function() onExit, required this.child,
  }) : _onExit = onExit;
  //
  @override
  State<ExitListeningWidget> createState() => _ExitListeningWidgetState();
}
///
class _ExitListeningWidgetState extends State<ExitListeningWidget> {
  late final AppLifecycleListener _listener;
  //
  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onExitRequested: () async {
        await widget._onExit();
        return AppExitResponse.exit;
      },
    );
  }
  //
  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }
  //
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}