import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/pages/reports/provider/photo_sanitizer.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:image/image.dart' as img;

bool _contains(Uint8List bytes, String text) =>
    String.fromCharCodes(bytes).contains(text);

void main() {
  group('splitReportText', () {
    test('uses the first sentence as the title', () {
      final text = splitReportText('Хүйтэн ус алга. Хошуу гоожиж байна.');
      expect(text.title, 'Хүйтэн ус алга');
      expect(text.detail, 'Хошуу гоожиж байна.');
    });

    test('keeps a single sentence whole', () {
      final text = splitReportText('23:00-с хойш чанга хөгжим');
      expect(text.title, '23:00-с хойш чанга хөгжим');
      expect(text.detail, '');
    });

    test('splits on a new line', () {
      expect(splitReportText('Гарчиг\nДэлгэрэнгүй').detail, 'Дэлгэрэнгүй');
    });
  });

  group('reportAge', () {
    final now = DateTime.utc(2026, 11, 9, 14, 37); // 22:37 in Ulaanbaatar.

    test('is recent within the first hour', () {
      final age = reportAge(DateTime.utc(2026, 11, 9, 14), now);
      expect(age.kind, ReportAgeKind.recent);
    });

    test('counts whole hours the same day', () {
      final age = reportAge(DateTime.utc(2026, 11, 9, 12), now);
      expect(age.kind, ReportAgeKind.hours);
      expect(age.hours, 2);
    });

    test('uses the Ulaanbaatar calendar for yesterday', () {
      // 15:00 UTC on the 8th is already 23:00 on the 8th in Ulaanbaatar.
      expect(
        reportAge(DateTime.utc(2026, 11, 8, 15), now).kind,
        ReportAgeKind.yesterday,
      );
      // 16:00 UTC on the 8th is 00:00 on the 9th there, so still today.
      expect(
        reportAge(DateTime.utc(2026, 11, 8, 16), now).kind,
        ReportAgeKind.hours,
      );
    });

    test('shows only a short date when older', () {
      final age = reportAge(DateTime.utc(2026, 11, 5, 3), now);
      expect(age.kind, ReportAgeKind.date);
      expect(age.date, '11/5');
    });
  });

  group('sanitizeReportPhoto', () {
    Uint8List photoWithExif({int width = 16, int height = 16}) {
      final image = img.Image(width: width, height: height);
      image.exif.imageIfd['Make'] = 'SECRET-CAMERA';
      image.exif.imageIfd['ImageDescription'] = 'GPS-47.9184N';
      return img.encodeJpg(image);
    }

    test('removes EXIF data', () {
      final original = photoWithExif();
      expect(_contains(original, 'SECRET-CAMERA'), isTrue);

      final clean = sanitizeReportPhoto(original);

      expect(_contains(clean, 'SECRET-CAMERA'), isFalse);
      expect(_contains(clean, 'GPS-47.9184N'), isFalse);
      expect(_contains(clean, 'Exif'), isFalse);
    });

    test('limits the size', () {
      final clean = sanitizeReportPhoto(
        photoWithExif(width: 2000, height: 1000),
      );
      final decoded = img.decodeJpg(clean)!;
      expect(decoded.width, 1280);
      expect(decoded.height, 640);
    });

    test('refuses what is not an image', () {
      expect(
        () => sanitizeReportPhoto(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  test('Report ignores anything about the author', () {
    final report = Report.fromJson({
      'id': 'r1',
      'category': 'noise',
      'location': 'hall',
      'description': 'text',
      'status': 'in_progress',
      'reply': null,
      'has_photo': false,
      'created_at': '2026-11-09T14:00:00.000Z',
      'vote_count': 3,
      'voted': true,
      'user_id': 'someone',
      'author_hash': 'abc',
    });

    expect(report.status, ReportStatus.inProgress);
    expect(report.voteCount, 3);
    expect(report.toString(), isNot(contains('someone')));
  });
}
