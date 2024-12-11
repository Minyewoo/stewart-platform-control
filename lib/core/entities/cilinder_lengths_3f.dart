///
class CilinderLengths3f {
  final double cilinder1;
  final double cilinder2;
  final double cilinder3;
  ///
  const CilinderLengths3f({
    this.cilinder1 = 0.0,
    this.cilinder2 = 0.0,
    this.cilinder3 = 0.0,
  });
  ///
  CilinderLengths3f addValue(num value) => CilinderLengths3f(
    cilinder1: cilinder1+value,
    cilinder2: cilinder2+value,
    cilinder3: cilinder3+value,
  );
  ///
  CilinderLengths3f addLengths(CilinderLengths3f lengths) => CilinderLengths3f(
    cilinder1: cilinder1+lengths.cilinder1,
    cilinder2: cilinder2+lengths.cilinder2,
    cilinder3: cilinder3+lengths.cilinder3,
  );
  ///
  ///
  CilinderLengths3f multiply(num value) => CilinderLengths3f(
    cilinder1: cilinder1*value,
    cilinder2: cilinder2*value,
    cilinder3: cilinder3*value,
  );
}