import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets? padding;

  /// Overrides the default border, for example to highlight a card.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GeneralColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? GeneralColors.borderColor,
          width: borderColor == null ? 1 : 1.5,
        ),
      ),
      child: child,
    );
  }
}
