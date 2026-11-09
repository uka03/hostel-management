import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Keeps input to 8 digits shown as `8097 7331`, and accepts a pasted
/// `+976` number.
class MnPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final nonDigits = RegExp(r'\D');
    var digits = newValue.text.replaceAll(nonDigits, '');
    var cursorDigits = newValue.text
        .substring(0, newValue.selection.end.clamp(0, newValue.text.length))
        .replaceAll(nonDigits, '')
        .length;

    if (digits.length == 11 && digits.startsWith('976')) {
      digits = digits.substring(3);
      cursorDigits = digits.length;
    }
    if (digits.length > 8) digits = digits.substring(0, 8);
    if (cursorDigits > digits.length) cursorDigits = digits.length;

    final text = groupMnDigits(digits);
    final offset = cursorDigits > 4 ? cursorDigits + 1 : cursorDigits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.isValid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isValid;
  final ValueChanged<String> onChanged;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: GeneralColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused
              ? GeneralColors.primaryColor
              : GeneralColors.borderColor,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: [
          if (focused)
            const BoxShadow(
              color: GeneralColors.primarySoftColor,
              spreadRadius: 4,
            ),
        ],
      ),
      child: Row(
        children: [
          const _MongolianFlag(),
          HSpacer.sm(),
          Text(
            '+976',
            style: GeneralTextStyle.bodyText(
              fontSize: 16,
              textColor: GeneralColors.mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          HSpacer.sm(),
          Container(width: 1, height: 24, color: GeneralColors.borderColor),
          HSpacer.sm(),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [MnPhoneInputFormatter()],
              onChanged: widget.onChanged,
              cursorColor: GeneralColors.primaryColor,
              style: GeneralTextStyle.titleText(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              // Explicit, because the app theme adds outlines to every field.
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          if (widget.isValid)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: GeneralColors.successSoftColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.check,
                size: 14,
                color: GeneralColors.successColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _MongolianFlag extends StatelessWidget {
  const _MongolianFlag();

  @override
  Widget build(BuildContext context) {
    Widget stripe(Color color) => Expanded(
      child: ColoredBox(color: color, child: const SizedBox.expand()),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 24,
        height: 16,
        child: Row(
          children: [
            stripe(GeneralColors.flagRedColor),
            stripe(GeneralColors.flagBlueColor),
            stripe(GeneralColors.flagRedColor),
          ],
        ),
      ),
    );
  }
}
