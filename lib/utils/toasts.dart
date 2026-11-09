import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Toast {
  Toast._();

  static void success(
    BuildContext context, {
    String? description,
    String? title,
  }) {
    _show(
      context,
      icon: LucideIcons.circleCheck,
      iconColor: GeneralColors.successColor,
      backgroundColor: GeneralColors.successSoftColor,
      title: title ?? AppLocalizations.of(context).toastSuccessTitle,
      description: description,
    );
  }

  static void error(
    BuildContext context, {
    String? description,
    String? title,
  }) {
    final l10n = AppLocalizations.of(context);
    _show(
      context,
      icon: LucideIcons.circleX,
      iconColor: GeneralColors.dangerColor,
      backgroundColor: GeneralColors.dangerSoftColor,
      title: title ?? l10n.toastErrorTitle,
      description: description ?? l10n.toastErrorDescription,
    );
  }

  static void _show(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    String? description,
  }) {
    final fToast = FToast()..init(context);
    fToast.removeCustomToast();
    fToast.showToast(
      toastDuration: const Duration(seconds: 3),
      gravity: ToastGravity.TOP,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: GeneralColors.mutedColor.withValues(alpha: 0.15),
              offset: const Offset(1, 0),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            HSpacer.sm(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GeneralTextStyle.sectionText()),
                  if (description != null) ...[
                    VSpacer.xs(),
                    Text(description, style: GeneralTextStyle.bodyText()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
