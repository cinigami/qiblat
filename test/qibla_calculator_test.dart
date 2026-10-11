import 'package:flutter_test/flutter_test.dart';
import 'package:qiblat/qibla_calculator.dart';

void main() {
  group('calculateQiblaBearing', () {
    test('returns ~291° for Kedah (Alor Setar)', () {
      final bearing = calculateQiblaBearing(6.1254, 100.3673);
      expect(bearing, closeTo(291.2, 0.5));
    });

    test('returns ~293° for Kuala Lumpur', () {
      final bearing = calculateQiblaBearing(3.1390, 101.6869);
      expect(bearing, closeTo(292.5, 0.5));
    });

    test('returns value between 0 and 360', () {
      final bearing = calculateQiblaBearing(6.1254, 100.3673);
      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThan(360.0));
    });
  });

  group('normalizeArrowRotation', () {
    test('returns 0 when phone faces exactly Qibla direction', () {
      expect(normalizeArrowRotation(292.0, 292.0), closeTo(0.0, 0.001));
    });

    test('returns 90 when phone is 90° off Qibla', () {
      expect(normalizeArrowRotation(292.0, 202.0), closeTo(90.0, 0.001));
    });

    test('wraps correctly when qibla < heading', () {
      final rotation = normalizeArrowRotation(10.0, 350.0);
      expect(rotation, closeTo(20.0, 0.001));
    });

    test('returns 10 for (5, 355)', () {
      final rotation = normalizeArrowRotation(5.0, 355.0);
      expect(rotation, closeTo(10.0, 0.001));
    });
  });

  group('isAlignedWithQibla', () {
    test('true when arrow rotation is 2° (near 0)', () {
      expect(isAlignedWithQibla(2.0), isTrue);
    });

    test('true when arrow rotation is 358° (near 360)', () {
      expect(isAlignedWithQibla(358.0), isTrue);
    });

    test('false when 10° off', () {
      expect(isAlignedWithQibla(10.0), isFalse);
    });

    test('false when 180° (facing away)', () {
      expect(isAlignedWithQibla(180.0), isFalse);
    });
  });
}
