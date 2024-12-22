import 'package:flutter/material.dart';
///
class MessageDisplay extends StatelessWidget {
  final Stream<String> _messagesStream;
  ///
  const MessageDisplay({
    super.key,
    required Stream<String> messagesStream,
  }) : _messagesStream = messagesStream;
  //
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: StreamBuilder<String>(
        initialData: '',
        stream: _messagesStream,
        builder: (context, snapshot) {
          final message = snapshot.data.toString();
          return ClipRect(
            child: Padding(
              padding: Theme.of(context).buttonTheme.padding,
              child: _AnimatedMessage(
                message: message,
              ),
            ),
          );
        },
      ),
    );
  }
}
///
class _AnimatedMessage extends StatelessWidget {
  final _offsetReverser = _Reverser(value: 3.0);
  final String _message;
  ///
  _AnimatedMessage({
    required String message,
  }) : _message = message;
  //
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(0, _offsetReverser.value),
            end: Offset.zero
          )
        ),
        child: child,
      ),
      child: Text(
        _message,
        key: UniqueKey(),
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
///
class _Reverser {
  final double _value;
  int factor = 1;
  ///
  _Reverser({required double value}) : _value = value;
  ///
  double get value {
    final result = _value*factor;
    factor *= -1;
    return result;
  }
}