import 'package:flutter/material.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/sines/message_display.dart';
///
class PlatformControlAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool _isPlatformMoving;
  final Stream<String> _messagesStream;
  // final void Function() _onSaveSines;
  final void Function() _onPlayFile;
  final void Function() _onStartFluctuations;
  final void Function() _onZeroPositionRequest;
  final void Function() _onMaxPositionRequest;
  final void Function() _onMinPositionRequest;
  final void Function() _onPlatformStop;
  @override
  final Size preferredSize;
  ///
  const PlatformControlAppBar({
    super.key,
    required void Function() onSave,
    required void Function() onStartFluctuations,
    required void Function() onPlayFile,
    required void Function() onZeroPositionRequest,
    required void Function() onMaxPositionRequest,
    required void Function() onMinPositionRequest,
    required void Function() onPlatformStop,
    required bool isPlatformMoving,
    required Stream<String> messagesStream,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  }) :
    _onPlayFile = onPlayFile,
    _isPlatformMoving = isPlatformMoving,
    _onPlatformStop = onPlatformStop,
    _onStartFluctuations = onStartFluctuations,
    _onZeroPositionRequest = onZeroPositionRequest,
    _onMaxPositionRequest = onMaxPositionRequest,
    _onMinPositionRequest = onMinPositionRequest,
    _messagesStream = messagesStream;
    // _onSaveSines = onSave;
  //
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 1200;
        return AppBar(
          actions: [
            Expanded(
              child: Padding(
                padding: Theme.of(context).buttonTheme.padding,
                child: MessageDisplay(
                  messagesStream: _messagesStream,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _isPlatformMoving ? null : _onMaxPositionRequest,
                icon: const Icon(Icons.expand_less_rounded),
                tooltip: 'В максимум',
              ) : FilledButton.icon(
                onPressed: _isPlatformMoving ? null : _onMaxPositionRequest,
                icon: const Icon(Icons.expand_less_rounded),
                label: const Text('В максимум'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _isPlatformMoving ? null : _onMinPositionRequest,
                icon: const Icon(Icons.expand_more_rounded),
                tooltip: 'В минимум',
              ) : FilledButton.icon(
                onPressed: _isPlatformMoving ? null : _onMinPositionRequest,
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('В минимум'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _isPlatformMoving ? null : _onZeroPositionRequest,
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Нулевая позиция',
              ) : FilledButton.icon(
                onPressed: _isPlatformMoving ? null : _onZeroPositionRequest,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Нулевая позиция'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _isPlatformMoving ? null : _onPlayFile,
                icon: const Icon(Icons.file_upload_rounded),
                tooltip: 'Файл',
              ) : FilledButton.icon(
                onPressed: _isPlatformMoving ? null : _onPlayFile,
                icon: const Icon(Icons.file_upload_rounded),
                label: const Text('Файл'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _isPlatformMoving ? null : _onStartFluctuations,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Старт',
              ) : FilledButton.icon(
                onPressed: _isPlatformMoving ? null : _onStartFluctuations,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Старт'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isTight ? IconButton(
                onPressed: _onPlatformStop,
                icon: const Icon(Icons.stop),
                tooltip: 'Стоп',
              ) : FilledButton.icon(
                onPressed: _onPlatformStop, 
                icon: const Icon(Icons.stop), 
                label: const Text('Стоп'),
              ),
            ),
          ],
        );
      },
    );
  }
}