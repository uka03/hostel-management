import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A labelled value with a copy button, e.g. the number to text.
class CopyRow extends StatefulWidget {
  const CopyRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label, value;
  final Color? valueColor;

  @override
  State<CopyRow> createState() => _CopyRowState();
}

class _CopyRowState extends State<CopyRow> {
  Timer? _resetTimer;
  bool _copied = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: GeneralTextStyle.bodyText(
                  textColor: GeneralColors.mutedColor,
                ),
              ),
              VSpacer.xs(),
              Text(
                widget.value,
                style: GeneralTextStyle.titleText(
                  textColor: widget.valueColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        CustomButton(
          onTap: _copy,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: GeneralColors.primarySoftColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _copied ? LucideIcons.check : LucideIcons.copy,
                  size: 16,
                  color: GeneralColors.primaryColor,
                ),
                HSpacer.xs(),
                Text(
                  _copied ? l10n.authSmsCopied : l10n.authSmsCopy,
                  style: GeneralTextStyle.bodyText(
                    textColor: GeneralColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
