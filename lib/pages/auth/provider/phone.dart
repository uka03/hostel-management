/// Formats up to 8 digits for display, e.g. `8097 7331`.
String groupMnDigits(String digits) => digits.length <= 4
    ? digits
    : '${digits.substring(0, 4)} ${digits.substring(4)}';

/// Display form of an E.164 number, e.g. `+97680977331` to `8097 7331`.
String displayMnPhone(String phone) =>
    groupMnDigits(phone.replaceAll(RegExp(r'^\+976'), ''));

/// Hides the last digits, e.g. `97680977331` to `+976 8097 ****`.
String? maskMnPhone(String phone) {
  final match = RegExp(r'^\+?976(\d{4})\d{4}$').firstMatch(phone);
  return match == null ? null : '+976 ${match[1]} ****';
}

/// Converts user input to E.164 (`+976XXXXXXXX`), or null if it isn't a valid
/// 8-digit Mongolian number.
String? normalizeMnPhone(String input) {
  var digits = input.replaceAll(RegExp(r'[\s\-]'), '');
  if (digits.startsWith('+976')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('976') && digits.length == 11) {
    digits = digits.substring(3);
  }
  return RegExp(r'^\d{8}$').hasMatch(digits) ? '+976$digits' : null;
}
