import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hostel/connection/model/phone_verification.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/copy_row.dart';
import 'package:hostel/pages/auth/components/notice_banner.dart';
import 'package:hostel/pages/auth/components/sms_status_card.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// The resident texts a code to 144773; this page waits for it to arrive.
class SmsVerifyPage extends StatefulWidget {
  const SmsVerifyPage({super.key, required this.phone});

  final String phone;

  @override
  State<SmsVerifyPage> createState() => _SmsVerifyPageState();
}

class _SmsVerifyPageState extends State<SmsVerifyPage> {
  PhoneVerification? _verification;
  bool _expired = false;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      final verified = await context.read<AuthProvider>().verifyPhone(
        widget.phone,
        onStarted: _showVerification,
        isCancelled: () => !mounted,
      );
      if (!mounted) return;
      _countdown?.cancel();
      if (verified) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => _expired = true);
      }
    } catch (_) {
      if (!mounted) return;
      _countdown?.cancel();
      Toast.error(context);
      Navigator.of(context).pop();
    }
  }

  void _showVerification(PhoneVerification verification) {
    if (!mounted) return;
    setState(() => _verification = verification);
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _requestNewCode() {
    setState(() {
      _verification = null;
      _expired = false;
    });
    _verify();
  }

  Duration _remaining(PhoneVerification verification) {
    final left = verification.expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> _openSms(String smsUri) async {
    final message = AppLocalizations.of(context).authSmsOpenFailed;
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(smsUri));
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) Toast.error(context, description: message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = displayMnPhone(widget.phone);
    final verification = _verification;
    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  VSpacer.lg(),
                  const IconBox(
                    icon: LucideIcons.messageSquare,
                    backgroundColor: GeneralColors.primarySoftColor,
                    iconColor: GeneralColors.primaryColor,
                  ),
                  VSpacer.md(),
                  Text(
                    l10n.authSmsTitle,
                    style: GeneralTextStyle.titleText(
                      fontSize: 28,
                      height: 1.2,
                    ),
                  ),
                  VSpacer.sm(),
                  _Subtitle(text: l10n.authSmsSubtitle(phone), phone: phone),
                  VSpacer.lg(),
                  ..._details(l10n, phone, verification),
                ],
              ),
            ),
          ),
          VSpacer.md(),
          if (_expired)
            PrimaryButton(
              height: 56,
              title: l10n.authSmsNewCode,
              onPressed: _requestNewCode,
            )
          else if (verification != null) ...[
            PrimaryButton(
              height: 56,
              onPressed: () => _openSms(verification.smsUri),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.messageSquare,
                    size: 20,
                    color: GeneralColors.onPrimaryColor,
                  ),
                  HSpacer.sm(),
                  Flexible(
                    child: Text(
                      l10n.authSmsOpen,
                      style: GeneralTextStyle.sectionText(
                        textColor: GeneralColors.onPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VSpacer.sm(),
            Text(
              l10n.authSmsCost,
              textAlign: TextAlign.center,
              style: GeneralTextStyle.captionText(),
            ),
          ],
          VSpacer.xs(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.authSmsChangeNumber,
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

  List<Widget> _details(
    AppLocalizations l10n,
    String phone,
    PhoneVerification? verification,
  ) {
    if (_expired) {
      return [
        NoticeBanner(
          icon: LucideIcons.circleAlert,
          text: l10n.authSmsExpired,
          backgroundColor: GeneralColors.dangerSoftColor,
          textColor: GeneralColors.dangerColor,
        ),
      ];
    }
    if (verification == null) {
      return [VSpacer.xl(), const Center(child: CircularProgressIndicator())];
    }
    return [
      AppCard(
        child: Column(
          children: [
            CopyRow(
              label: l10n.authSmsRecipient,
              value: verification.recipient,
            ),
            const Divider(height: 28, color: GeneralColors.borderColor),
            CopyRow(
              label: l10n.authSmsMessage,
              value: verification.code,
              valueColor: GeneralColors.primaryColor,
            ),
          ],
        ),
      ),
      VSpacer.md(),
      NoticeBanner(
        icon: LucideIcons.info,
        text: l10n.authSmsDualSim(phone),
        backgroundColor: GeneralColors.warningSoftColor,
        textColor: GeneralColors.warningTextColor,
      ),
      VSpacer.md(),
      SmsStatusCard(remaining: _remaining(verification)),
    ];
  }
}

/// The instruction text with the phone number emphasised.
class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.text, required this.phone});

  final String text, phone;

  @override
  Widget build(BuildContext context) {
    final start = text.indexOf(phone);
    return Text.rich(
      TextSpan(
        style: GeneralTextStyle.bodyText(
          fontSize: 14.5,
          textColor: GeneralColors.mutedColor,
          height: 1.5,
        ),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: phone,
            style: GeneralTextStyle.bodyText(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          TextSpan(text: text.substring(start + phone.length)),
        ],
      ),
    );
  }
}
