import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.name,
    required this.phone,
    required this.roleLabel,
    required this.activeCount,
  });

  final String name, roleLabel;
  final String? phone;
  final int? activeCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const onCard = GeneralColors.onPrimaryColor;
    final count = activeCount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GeneralColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: onCard,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  name.isEmpty ? '' : name.characters.first.toUpperCase(),
                  style: GeneralTextStyle.titleText(
                    fontSize: 20,
                    textColor: GeneralColors.primaryColor,
                  ),
                ),
              ),
              HSpacer(size: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GeneralTextStyle.titleText(
                        fontSize: 18,
                        textColor: onCard,
                      ),
                    ),
                    if (phone case final phone?) ...[
                      VSpacer(size: 2),
                      Text(
                        phone,
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.primarySoftColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              HSpacer.sm(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: onCard.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  roleLabel,
                  style: GeneralTextStyle.captionText(
                    textColor: onCard,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 28, color: onCard.withValues(alpha: 0.2)),
          Row(
            children: [
              const Icon(LucideIcons.house, size: 16, color: onCard),
              HSpacer.sm(),
              Expanded(
                child: Text(
                  l10n.profileApartment,
                  style: GeneralTextStyle.bodyText(
                    textColor: onCard,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  l10n.profileResidentCount(count),
                  style: GeneralTextStyle.bodyText(
                    textColor: GeneralColors.primarySoftColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
