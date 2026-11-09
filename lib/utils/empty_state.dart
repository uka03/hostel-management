import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.title, this.imagePath, this.fontSize});
  final String? title;
  final String? imagePath;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            Image.asset(imagePath!, height: 190)
          else
            const Icon(
              LucideIcons.inbox,
              size: 48,
              color: GeneralColors.mutedColor,
            ),
          VSpacer(),
          Text(
            title ?? AppLocalizations.of(context).emptyDefault,
            style: GeneralTextStyle.bodyText(fontSize: fontSize ?? 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
