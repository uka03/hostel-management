import 'package:flutter/material.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: GeneralColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GeneralColors.borderColor),
        ),
        child: const Icon(
          LucideIcons.chevronLeft,
          size: 22,
          color: GeneralColors.textColor,
        ),
      ),
    );
  }
}
