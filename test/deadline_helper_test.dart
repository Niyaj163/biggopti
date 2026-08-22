import 'package:flutter_test/flutter_test.dart';
import 'package:biggopti/core/utils/deadline_helper.dart';

void main() {
  group('DeadlineHelper Tests', () {
    test('Correctly parses Bangla date string with Bangla digits', () {
      final parsed = DeadlineHelper.parseDeadline('২৮ আগস্ট ২০২৬');
      expect(parsed, isNotNull);
      expect(parsed!.day, 28);
      expect(parsed.month, 8);
      expect(parsed.year, 2026);
    });

    test('Correctly identifies future deadline as active', () {
      final active = DeadlineHelper.isActive('৩০ ডিসেম্বর ২০২৬');
      expect(active, isTrue);
    });

    test('Correctly identifies past deadline as expired', () {
      final expired = DeadlineHelper.isExpired('০১ জানুয়ারি ২০২৪');
      expect(expired, isTrue);
    });

    test('Correctly handles English date string', () {
      final parsed = DeadlineHelper.parseDeadline('15 September 2026');
      expect(parsed, isNotNull);
      expect(parsed!.day, 15);
      expect(parsed.month, 9);
      expect(parsed.year, 2026);
    });

    test('Handles unspecified deadline safely without crashing', () {
      final active = DeadlineHelper.isActive('নির্দিষ্ট নয়');
      expect(active, isTrue);
    });
  });
}
