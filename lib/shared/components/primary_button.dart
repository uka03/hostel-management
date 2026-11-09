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
    this.height = 48,
    this.disabledColor,
  });
  final VoidCallback onPressed;
  final Widget? content;
  final String? title;
  final Color? backgroundColor, textColor;
  final double? radius;
  final bool isEnable;
  final double height;
  final Color? disabledColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isEnable ? onPressed : null,
        style: ButtonStyle(
          elevation: WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            isEnable
                ? backgroundColor ?? GeneralColors.primaryColor
                : disabledColor ?? GeneralColors.mutedColor,
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
