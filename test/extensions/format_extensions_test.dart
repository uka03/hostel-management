import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/extensions/date_extensions.dart';
import 'package:hostel/extensions/int_extensions.dart';

void main() {
  group('toMnt', () {
    test('groups thousands', () {
      expect(48600.toMnt(), '₮48,600');
      expect(1000000.toMnt(), '₮1,000,000');
    });

    test('handles zero and negatives', () {
      expect(0.toMnt(), '₮0');
      expect((-4500).toMnt(), '-₮4,500');
    });
  });

  group('mnShort', () {
    test('uses Ulaanbaatar date across the UTC day boundary', () {
      expect(DateTime.utc(2026, 11, 8, 15, 59).mnShort(), '11/8');
      expect(DateTime.utc(2026, 11, 8, 16, 0).mnShort(), '11/9');
    });
  });
}
