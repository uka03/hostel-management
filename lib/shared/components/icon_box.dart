import 'package:flutter/material.dart';

class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 56,
    this.iconSize = 28,
    this.radius = 18,
  });

  final IconData icon;
  final Color backgroundColor, iconColor;
  final double size, iconSize, radius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
