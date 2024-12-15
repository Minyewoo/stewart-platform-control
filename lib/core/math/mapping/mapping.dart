import 'package:stewart_platform_control/core/math/min_max.dart';

///
abstract interface class Mapping<I, O> {
  const factory Mapping.generic({
    required O Function(I) mappingFunction,
  }) = _GenericMapping<I,O>;
  ///
  O of(I x);
}
///
abstract interface class MinMaxedMapping<I, O> implements Mapping<I, O> {
  ///
  MinMax<O> get minMax;
}
///
class _GenericMapping<I, O> implements Mapping<I, O> {
  final O Function(I) _mappingFunction;
  ///
  const _GenericMapping({
    required O Function(I) mappingFunction,
  }) : 
    _mappingFunction = mappingFunction;
  //
  @override
  O of(I x) => _mappingFunction(x);
}