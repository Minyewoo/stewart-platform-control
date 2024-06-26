import 'package:stewart_platform_control/core/io/controller/package/byte_sequence.dart';
///
class PassCode implements ByteSequence {
  final Iterable<int> _bytes;
  ///
  const PassCode._(this._bytes);
  /// 
  /// Should contain 2 bytes
  const factory PassCode.fromIterable(Iterable<int> bytes) = PassCode._;
  ///
  /// No pass code
  const PassCode.none() : this._(const [0x00, 0x00]);
  //
  @override
  Iterable<int> get bytes => _bytes;

}