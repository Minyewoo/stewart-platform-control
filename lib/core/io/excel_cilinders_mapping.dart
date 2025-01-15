import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:stewart_platform_control/core/entities/cilinder_lengths_3f.dart';
import 'package:stewart_platform_control/core/math/mapping/absolute_time_mapping.dart';
import 'package:stewart_platform_control/core/math/mapping/time_mapping.dart';
import 'package:stewart_platform_control/core/math/min_max.dart';
import 'package:stewart_platform_control/core/platform/platform_state.dart';

///
class ExcelCilindersMapping {
  static const _log = Log('ExcelCilindersMapping');
  final String _filePath;
  ///
  const ExcelCilindersMapping({
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
    final data = sheet?.rows.skip(1).map(
      (row) {
        // print('Row[0]: ${row[1]?.value.toString()}');
        if(row.length < 4) {
          return null;
        }
        final duration = switch(row[0]?.value) {
          DoubleCellValue(:final value) => Duration(
            milliseconds: (value*1000).toInt(),
          ),
          _ => null,
        };
        // print('Duration: ${duration.inMilliseconds}');
        final cilinderValues = [
          for(int i = 1; i <= 3; i++)
            _parseCilinderValue(row[i]?.value)
        ];
        if(duration == null || cilinderValues.any((value) => value == null)) {
          return null;
        }
        return AbsoluteTimeValue(
          absoluteDuration: duration,
          value: CilinderLengths3f(
            cilinder1: cilinderValues[0]!,
            cilinder2: cilinderValues[1]!,
            cilinder3: cilinderValues[2]!,
          ),
        );
      },
    )
    .where((value) => value != null)
    .map((value) => value!)
    .map((value) => value.map(_mapCilinders))
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
      minMax.min.beamsPosition.cilinder3,
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
  double? _parseCilinderValue(CellValue? cellValue) => switch(cellValue) {
    DoubleCellValue(:final value) => value,
    _ => null,
  };
  ///
  PlatformState _mapCilinders(CilinderLengths3f lengths, {double factor = 1.0}) {
    return PlatformState(
      beamsPosition: CilinderLengths3f(
        cilinder1: lengths.cilinder3,
        cilinder2: lengths.cilinder1,
        cilinder3: lengths.cilinder2,
      ),
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