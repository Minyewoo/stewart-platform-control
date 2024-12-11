import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:ditredi/ditredi.dart';
import 'package:excel/excel.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:stewart_platform_control/core/entities/cilinder_lengths_3f.dart';
import 'package:stewart_platform_control/core/entities/cilinders_extractions_3f.dart';
import 'package:stewart_platform_control/core/math/mapping/absolute_time_mapping.dart';
import 'package:stewart_platform_control/core/math/mapping/time_mapping.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/platform/platform_state.dart';

enum FluctuationType{
  vertical,
  unregular
}
///
class ExcelMapping {
  static const _log = Log('ExcelMapping');
  final String _filePath;
  ///
  const ExcelMapping({
    required String filePath,
  }) : _filePath = filePath;
  ///
  Future<Option<TimeMapping<PlatformState>>> timeMapping() async {
    _log.info('Reading mapping from $_filePath');
    final excel = Excel.decodeBytes(
      await File(_filePath).readAsBytes(),
    );
    final sheetName = excel.getDefaultSheet();
    final sheet = excel.tables[sheetName];
    final dataHeaderText = sheet?.cell(CellIndex.indexByString('B1')).value.toString();
    final fluctuationType = (dataHeaderText?.startsWith('Angle') ?? false) ? FluctuationType.unregular : FluctuationType.vertical;
    final mappingFunction = switch(fluctuationType) {
      FluctuationType.vertical => (double value) => _mapPosition(value, factor: 0.7),
      FluctuationType.unregular => (double value) => _mapAngle(value),
    };
    final data = sheet?.rows.skip(1).map(
      (row) {
        // print('Row[0]: ${row[1]?.value.toString()}');
        final duration = switch(row[0]?.value) {
          DoubleCellValue(:final value) => Duration(
            milliseconds: (value*1000).toInt(),
          ),
          _ => null,
        };
        if(duration == null) {
          return null;
        }
        // print('Duration: ${duration.inMilliseconds}');
        final value = switch(row[1]?.value) {
          DoubleCellValue(:final value) => value,
          _ => null,
        };
        if(value == null) {
          return null;
        }
        return AbsoluteTimeValue(
          absoluteDuration: duration,
          value: value,
        );
      },
    )
    .where((value) => value != null)
    .map((value) => value!)
    .map((value) => value.map(mappingFunction))
    .toList();
    if(data?.isEmpty ?? true) {
      return  const None();
    }
    final minMax = data!.map((target) => target.value).fold(
      MinMax(min: data.first.value, max: data.first.value),
      (minMax, element) {
        final min = _isStateLower(element, minMax.min) ? element : null;
        final max = _isStateGreater(element, minMax.max) ? element : null;
        return MinMax(min: min ?? minMax.min, max: max ?? minMax.max);
      },
    );
    final heightOffset = [
      minMax.min.beamsPosition.cilinder1,
      minMax.min.beamsPosition.cilinder2,
      minMax.min.beamsPosition.cilinder1,
    ].reduce(min).abs();
    final offsettedData = data.map(
      (value) => value.map(
        (state) => PlatformState(
          beamsPosition: state.beamsPosition.addValue(heightOffset),
          fluctuationAngles: state.fluctuationAngles,
        ),
      ),
    ).toList();
    return Some(
      AbsoluteTimeMapping(
        offsettedData.first.value,
        minMax: minMax,
        absoluteValues: offsettedData,
      )
    );
  }
  ///
  PlatformState _mapAngle(double angle, {double factor = 1.0}) {
    final radians = angle.toRadians();
    return PlatformState(
      beamsPosition: lengthsFunctionX.of(
        CilinderLengthsDependencies(
          fluctuationAngleRadians: radians,
          fluctuationCenterOffset: 0.0,
        ),
      ).multiply(factor),
      fluctuationAngles: Offset(radians, 0.0),
    );
  }
  ///
  PlatformState _mapPosition(double position, {double factor = 1.0}) {
    return PlatformState(
      beamsPosition: CilinderLengths3f(
        cilinder1: position,
        cilinder2: position,
        cilinder3: position,
      ).multiply(factor),
      fluctuationAngles: Offset(0.0, 0.0),
    );
  }
  ///
  bool _isStateLower(PlatformState current, PlatformState other) => [
    current.beamsPosition.cilinder1,
    current.beamsPosition.cilinder2,
    current.beamsPosition.cilinder3,
  ].reduce(min) < [
    other.beamsPosition.cilinder1,
    other.beamsPosition.cilinder2,
    other.beamsPosition.cilinder3,
  ].reduce(min);
  ///
  bool _isStateGreater(PlatformState current, PlatformState other) => [
    current.beamsPosition.cilinder1,
    current.beamsPosition.cilinder2,
    current.beamsPosition.cilinder3,
  ].reduce(max) > [
    other.beamsPosition.cilinder1,
    other.beamsPosition.cilinder2,
    other.beamsPosition.cilinder3,
  ].reduce(max);
}