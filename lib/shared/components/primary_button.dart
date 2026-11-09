import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.content,
    this.title,
    this.backgroundColor,
    required this.onPressed,
    this.textColor,
    this.radius,
    this.isEnable = true,
  });
  final VoidCallback onPressed;
  final Widget? content;
  final String? title;
  final Color? backgroundColor, textColor;
  final double? radius;
  final bool isEnable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isEnable ? onPressed : null,
        style: ButtonStyle(
          elevation: WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            isEnable
                ? backgroundColor ?? GeneralColors.primaryColor
                : GeneralColors.mutedColor,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 14),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child:
                  content ??
                  Text(
                    title ?? '',
                    textAlign: TextAlign.center,
                    style: GeneralTextStyle.sectionText(
                      textColor: textColor ?? GeneralColors.onPrimaryColor,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
