import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/auth/components/phone_field.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/pages/auth/sms_verify_page.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _controller = TextEditingController();

  String? get _phone => normalizeMnPhone(_controller.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phone;
    if (phone == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SmsVerifyPage(phone: phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isValid = _phone != null;
    final linkStyle = GeneralTextStyle.captionText(
      textColor: GeneralColors.primaryColor,
      fontWeight: FontWeight.w600,
      height: 1.5,
    );
    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const IconBox(
                  icon: LucideIcons.house,
                  backgroundColor: GeneralColors.primaryColor,
                  iconColor: GeneralColors.onPrimaryColor,
                  size: 64,
                  iconSize: 30,
                  radius: 20,
                ),
                VSpacer.lg(),
                Text(
                  l10n.authPhoneTitle,
                  style: GeneralTextStyle.titleText(fontSize: 28, height: 1.2),
                ),
                VSpacer.sm(),
                Text(
                  l10n.authPhoneSubtitle,
                  style: GeneralTextStyle.bodyText(
                    fontSize: 14.5,
                    textColor: GeneralColors.mutedColor,
                    height: 1.5,
                  ),
                ),
                VSpacer.xl(),
                Text(
                  l10n.authPhoneLabel,
                  style: GeneralTextStyle.bodyText(fontWeight: FontWeight.w600),
                ),
                VSpacer.sm(),
                PhoneField(
                  controller: _controller,
                  isValid: isValid,
                  onChanged: (_) => setState(() {}),
                ),
                VSpacer.sm(),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.lock,
                      size: 14,
                      color: GeneralColors.mutedColor,
                    ),
                    HSpacer(size: 6),
                    Expanded(
                      child: Text(
                        l10n.authPhonePrivacy,
                        style: GeneralTextStyle.captionText(),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                VSpacer.lg(),
                PrimaryButton(
                  height: 56,
                  isEnable: isValid,
                  onPressed: _submit,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.authContinue,
                          style: GeneralTextStyle.sectionText(
                            textColor: GeneralColors.onPrimaryColor,
                          ),
                        ),
                      ),
                      HSpacer.sm(),
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 20,
                        color: GeneralColors.onPrimaryColor,
                      ),
                    ],
                  ),
                ),
                VSpacer.md(),
                Text.rich(
                  TextSpan(
                    style: GeneralTextStyle.captionText(height: 1.5),
                    children: [
                      TextSpan(text: l10n.authTermsPrefix),
                      TextSpan(text: l10n.authTermsService, style: linkStyle),
                      TextSpan(text: l10n.authTermsJoin),
                      TextSpan(text: l10n.authTermsPrivacy, style: linkStyle),
                      TextSpan(text: l10n.authTermsSuffix),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
