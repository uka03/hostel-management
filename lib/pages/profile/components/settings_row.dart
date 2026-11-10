import 'package:flutter/material.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor, iconBackground;
  final String title;
  final String? subtitle, value;

  /// Replaces the chevron, for example with a switch.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: IconBox(
                icon: icon,
                backgroundColor: iconBackground,
                iconColor: iconColor,
                size: 36,
                iconSize: 18,
                radius: 10,
              ),
            ),
            HSpacer(size: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GeneralTextStyle.bodyText(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle case final subtitle?) ...[
                    VSpacer(size: 2),
                    Text(subtitle, style: GeneralTextStyle.captionText()),
                  ],
                ],
              ),
            ),
            if (value case final value?) ...[
              HSpacer.sm(),
              Text(
                value,
                style: GeneralTextStyle.bodyText(
                  textColor: GeneralColors.mutedColor,
                ),
              ),
            ],
            HSpacer.xs(),
            trailing ??
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: GeneralColors.mutedColor,
                ),
          ],
        ),
      ),
    );
  }
}
