import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/model/phone_verification.dart';
import 'package:hostel/pages/auth/components/phone_field.dart';
import 'package:hostel/pages/auth/provider/phone.dart';

TextEditingValue _typed(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

void main() {
  final formatter = MnPhoneInputFormatter();
  TextEditingValue format(TextEditingValue value) =>
      formatter.formatEditUpdate(TextEditingValue.empty, value);

  group('MnPhoneInputFormatter', () {
    test('groups digits 4 + 4', () {
      expect(format(_typed('8097')).text, '8097');
      expect(format(_typed('80977')).text, '8097 7');
      expect(format(_typed('80977331')).text, '8097 7331');
    });

    test('drops non-digits and anything past 8 digits', () {
      expect(format(_typed('80a9-7733199')).text, '8097 7331');
    });

    test('accepts a pasted international number', () {
      final result = format(_typed('+976 8097 7331'));
      expect(result.text, '8097 7331');
      expect(result.selection.end, 9);
    });

    test('keeps the cursor in place when editing the middle', () {
      // Typing "5" after "80" in "8097 7331".
      final result = format(_typed('80597 7331', 3));
      expect(result.text, '8059 7733');
      expect(result.selection.end, 3);
    });

    test('formatted text is a valid number', () {
      expect(normalizeMnPhone(format(_typed('80977331')).text), '+97680977331');
    });
  });

  test('displayMnPhone formats E.164 numbers', () {
    expect(displayMnPhone('+97680977331'), '8097 7331');
  });

  test('PhoneVerification reads recipient and code from the SMS link', () {
    final verification = PhoneVerification(
      sessionId: 's1',
      smsUri: 'sms:144773?body=343173',
      displayInstruction: 'instruction',
      expiresAt: DateTime.utc(2026),
    );
    expect(verification.recipient, '144773');
    expect(verification.code, '343173');
  });
}
