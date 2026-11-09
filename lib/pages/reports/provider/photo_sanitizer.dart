import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const _maxDimension = 1280;

/// Returns the photo re-encoded as a JPEG with all metadata removed, including
/// EXIF and GPS. The server does this again, so neither side relies on the
/// other. Throws a [FormatException] if the image can't be read.
Uint8List sanitizeReportPhoto(Uint8List source) {
  final decoded = img.decodeImage(source);
  if (decoded == null) throw const FormatException('unreadable image');

  var image = img.bakeOrientation(decoded);
  if (max(image.width, image.height) > _maxDimension) {
    image = image.width >= image.height
        ? img.copyResize(image, width: _maxDimension)
        : img.copyResize(image, height: _maxDimension);
  }

  image
    ..exif = img.ExifData()
    ..iccProfile = null
    ..textData = null;
  return img.encodeJpg(image, quality: 75);
}
