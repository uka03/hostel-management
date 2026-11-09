import 'package:flutter/material.dart';
import 'package:hostel/utils/text_styles.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color, backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GeneralTextStyle.captionText(
          textColor: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
