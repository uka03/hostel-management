import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Shown after sign-up until a manager approves the resident.
class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IconBox(
            icon: LucideIcons.clock,
            backgroundColor: GeneralColors.primarySoftColor,
            iconColor: GeneralColors.primaryColor,
          ),
          VSpacer.lg(),
          Text(
            l10n.authPendingTitle,
            style: GeneralTextStyle.titleText(fontSize: 28, height: 1.2),
          ),
          VSpacer.sm(),
          Text(
            l10n.authPendingBody,
            style: GeneralTextStyle.bodyText(
              fontSize: 14.5,
              textColor: GeneralColors.mutedColor,
              height: 1.5,
            ),
          ),
          const Spacer(),
          PrimaryButton(
            height: 56,
            title: l10n.authPendingCheck,
            onPressed: auth.refreshProfile,
          ),
          VSpacer.xs(),
          TextButton(
            onPressed: auth.signOut,
            child: Text(
              l10n.profileSignOut,
              style: GeneralTextStyle.bodyText(
                textColor: GeneralColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
