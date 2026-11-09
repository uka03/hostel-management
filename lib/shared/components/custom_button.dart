import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.child,
    required this.onTap,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color? splashColor, highlightColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      splashColor: splashColor ?? Colors.transparent,
      highlightColor: highlightColor ?? Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}
