import 'package:flutter/material.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/text_styles.dart';

/// A selectable pill, used for filters and categories.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = GeneralColors.primaryColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: CustomButton(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : GeneralColors.cardColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? selectedColor : GeneralColors.borderColor,
            ),
          ),
          child: Text(
            label,
            style: GeneralTextStyle.bodyText(
              textColor: isSelected
                  ? GeneralColors.onPrimaryColor
                  : GeneralColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
