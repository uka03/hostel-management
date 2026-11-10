import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/text_styles.dart';

/// A person's initial in a circle. The colour is stable for each person.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.personId, required this.name});

  static const size = 36.0;
  static const _colors = [
    (GeneralColors.warningColor, GeneralColors.warningSoftColor),
    (GeneralColors.successColor, GeneralColors.successSoftColor),
    (GeneralColors.primaryColor, GeneralColors.primarySoftColor),
    (GeneralColors.anonymousColor, GeneralColors.anonymousSoftColor),
  ];

  final String personId;
  final String name;

  @override
  Widget build(BuildContext context) {
    final index = personId.codeUnits.fold(0, (a, b) => a + b) % _colors.length;
    final (color, background) = _colors[index];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: GeneralTextStyle.sectionText(fontSize: 14, textColor: color),
      ),
    );
  }
}
