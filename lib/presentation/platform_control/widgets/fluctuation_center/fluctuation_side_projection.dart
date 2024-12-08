import 'package:flutter/material.dart';
import 'package:stewart_platform_control/core/canvas/letters/canvas_letter.dart';
import 'package:stewart_platform_control/core/entities/cilinder_lengths_3f.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/platform/platform_state.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_center/fluctuaction_center_picker_builder.dart';
import 'package:stewart_platform_control/presentation/platform_control/widgets/fluctuation_center/fluctuation_side_projection_paint.dart';
///
enum RotationAxis {
  y,
  x,
  both,
}
///
class FluctuationSideProjection extends StatelessWidget {
  final MinMax? _borderValues;
  final Stream<PlatformState> _platformState;
  final RotationAxis _type;
  final double _realPlatformDimention;
  final double _pointSize;
  final ValueNotifier<Offset> _fluctuationCenter;
  final bool _isPlatformMoving;
  ///
  const FluctuationSideProjection({
    super.key,
    required double realPlatformDimention,
    required ValueNotifier<Offset> fluctuationCenter,
    required Stream<PlatformState> platformState,
    required bool isPlatformMoving,
    RotationAxis type = RotationAxis.y,
    MinMax? borderValues,
    double pointSize = 9.0, 
  }) : 
    _platformState = platformState,
    _type = type,
    _borderValues = borderValues,
    _realPlatformDimention = realPlatformDimention,
    _fluctuationCenter = fluctuationCenter,
    _isPlatformMoving = isPlatformMoving,
    _pointSize = pointSize;
  //
  @override
  Widget build(BuildContext context) {
    // const horizontalRadius = cilindersPlacementRadius*sqrt3/2;
    const containerRadius = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: containerRadius,
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
      child: ClipRRect(
        borderRadius: containerRadius,
        child: FluctuationCenterPickerBuilder(
          isAxisReversed: switch(_type) {
            RotationAxis.y => true,
            RotationAxis.x => false,
            RotationAxis.both => false,
          },
          borderValues: _borderValues,
          isInteractive: !_isPlatformMoving,
          realPlatformDimention: _realPlatformDimention,
          fluctuationCenter: _fluctuationCenter,
          projectionType: _type,
          builder: (context, _, fluctuationCenter, __) {
            return _PlatformStateListener(
              borderValues: _borderValues,
              fluctuationCenter: fluctuationCenter,
              platformState: _platformState,
              type: _type,
              pointSize: _pointSize,
            );
          }
        ),
      ),
    );
  }
}
///
class _PlatformStateListener extends StatelessWidget {
  final MinMax? _borderValues;
  final Stream<PlatformState> _platformState;
  final RotationAxis _type;
  final double _pointSize;
  final Offset _fluctuationCenter;
  ///
  const _PlatformStateListener({
    required Stream<PlatformState> platformState,
    required RotationAxis type,
    required double pointSize,
    required Offset fluctuationCenter,
    MinMax? borderValues,
  }) : 
    _platformState = platformState,
    _type = type,
    _borderValues = borderValues,
    _fluctuationCenter = fluctuationCenter,
    _pointSize = pointSize;
  //
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: const PlatformState(
        fluctuationAngles: Offset.zero,
        beamsPosition: CilinderLengths3f(),
      ),
      stream: _platformState,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          final fluctuationAngles = snapshot.data!.fluctuationAngles;
          return FluctuationSideProjectionPaint(
            horizontalAxisName: switch(_type) {
              RotationAxis.y => CanvasLetterName.x,
              RotationAxis.x => CanvasLetterName.y,
              RotationAxis.both => CanvasLetterName.z,
            },
            borderValues: _borderValues,
            zAxisColor: Theme.of(context).colorScheme.onSurfaceVariant,
            accentColor: switch(_type) {
              RotationAxis.y => Colors.redAccent,
              RotationAxis.x => Colors.blueAccent,
              RotationAxis.both => Colors.purpleAccent,
            },
            fluctuationOffset: switch(_type) {
              RotationAxis.y => _fluctuationCenter.dy,
              RotationAxis.x => _fluctuationCenter.dx,
              RotationAxis.both => _fluctuationCenter.dx,
            },
            rotationRadians: switch(_type) {
              RotationAxis.y => fluctuationAngles.dy,
              RotationAxis.x => fluctuationAngles.dx,
              RotationAxis.both => fluctuationAngles.dx,
            },
            pointSize: _pointSize,
            isReversed: switch(_type) {
              RotationAxis.y
              || RotationAxis.both => false,
              RotationAxis.x => true,
            },
          );
        } else {
          return const SizedBox();
        }
      }
    );
  }
}