import 'package:flutter/material.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/connection/purchases_api.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/pages/profile/components/bank_account_sheet.dart';
import 'package:hostel/pages/profile/components/profile_hero_card.dart';
import 'package:hostel/pages/profile/components/settings_row.dart';
import 'package:hostel/pages/profile/provider/profile_provider.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/components/reload_when_visible.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<DioClient>().dio;
        return ProfileProvider(CleaningApi(dio), PurchasesApi(dio));
      },
      child: ReloadWhenVisible(
        onVisible: (context) => context.read<ProfileProvider>().load(
          context.read<AuthProvider>().user?.id,
        ),
        child: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  Future<void> _reload() => context.read<ProfileProvider>().load(
    context.read<AuthProvider>().user?.id,
  );

  Future<void> _attempt(Future<void> Function() change) async {
    try {
      await change();
    } catch (_) {
      if (mounted) Toast.error(context);
    }
  }

  Future<void> _editName(UserResponseData? user) async {
    final auth = context.read<AuthProvider>();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GeneralColors.cardColor,
      builder: (_) => _NameSheet(initial: user?.name ?? ''),
    );
    if (name != null) await _attempt(() => auth.saveName(name));
  }

  Future<void> _editAccount(UserResponseData? user) async {
    final auth = context.read<AuthProvider>();
    final input = await showBankAccountSheet(context, user);
    if (input == null) return;
    await _attempt(
      () => auth.savePaymentAccount(input.bank, input.number, input.holder),
    );
  }

  Future<void> _chooseLanguage(UserResponseData? user) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final language = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: GeneralColors.cardColor,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (code, label) in [
              ('mn', l10n.languageMongolian),
              ('en', l10n.languageEnglish),
            ])
              ListTile(
                title: Text(label),
                trailing: (user?.language ?? 'mn') == code
                    ? const Icon(
                        LucideIcons.check,
                        color: GeneralColors.primaryColor,
                      )
                    : null,
                onTap: () => Navigator.of(sheet).pop(code),
              ),
          ],
        ),
      ),
    );
    if (language != null) {
      await _attempt(() => auth.savePreferences(language: language));
    }
  }

  void _showInfo(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GeneralColors.cardColor,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GeneralTextStyle.sectionText()),
              VSpacer.sm(),
              Text(body, style: GeneralTextStyle.bodyText(height: 1.45)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.profileSignOutTitle),
        content: Text(l10n.profileSignOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cleaningCancelRequest),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              l10n.profileSignOut,
              style: GeneralTextStyle.bodyText(
                textColor: GeneralColors.dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = context.watch<ProfileProvider>().stats;
    final user = context.select<AuthProvider, UserResponseData?>((a) => a.user);
    final phone = context.select<AuthProvider, String?>((a) => a.phone);
    final auth = context.read<AuthProvider>();
    final balance = stats?.balance ?? 0;
    final account = user?.bankAccountNumber;
    final isEnglish = user?.language == 'en';
    const divider = Divider(
      height: 1,
      indent: 60,
      color: GeneralColors.borderColor,
    );

    return Scaffold(
      backgroundColor: GeneralColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tabProfile,
                      style: GeneralTextStyle.titleText(fontSize: 28),
                    ),
                  ),
                  Tooltip(
                    message: l10n.profileEditName,
                    child: CustomButton(
                      onTap: () => _editName(user),
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
                          LucideIcons.pencil,
                          size: 18,
                          color: GeneralColors.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              VSpacer.md(),
              ProfileHeroCard(
                name: user?.name ?? l10n.cleaningUnnamed,
                phone: phone == null ? null : maskMnPhone(phone),
                roleLabel: user?.role == UserRole.manager
                    ? l10n.profileRoleManager
                    : l10n.profileRoleResident,
                activeCount: stats?.activeCount,
              ),
              VSpacer(size: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Stat(
                        value: stats == null ? '—' : '${stats.cleanedCount}',
                        label: l10n.profileStatCleaned,
                      ),
                    ),
                    HSpacer.sm(),
                    Expanded(
                      child: _Stat(
                        value: stats?.nextTurn ?? '—',
                        label: l10n.profileStatNextTurn,
                      ),
                    ),
                    HSpacer.sm(),
                    Expanded(
                      child: _Stat(
                        value: stats == null ? '—' : balance.abs().toMnt(),
                        label: balance < 0
                            ? l10n.profileStatOwe
                            : l10n.profileStatGetBack,
                        valueColor: balance > 0
                            ? GeneralColors.successColor
                            : balance < 0
                            ? GeneralColors.warningTextColor
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              VSpacer(size: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: GeneralColors.cardColor,
                    child: Column(
                      children: [
                        SettingsRow(
                          icon: LucideIcons.landmark,
                          iconColor: GeneralColors.primaryColor,
                          iconBackground: GeneralColors.primarySoftColor,
                          title: l10n.profileBankTitle,
                          subtitle: account == null
                              ? l10n.profileBankNone
                              : '${user?.bankName ?? ''} · $account',
                          onTap: () => _editAccount(user),
                        ),
                        divider,
                        SettingsRow(
                          icon: LucideIcons.bell,
                          iconColor: GeneralColors.primaryColor,
                          iconBackground: GeneralColors.primarySoftColor,
                          title: l10n.profileNotifications,
                          trailing: Switch(
                            value: user?.notificationsEnabled ?? true,
                            activeTrackColor: GeneralColors.primaryColor,
                            onChanged: (value) => _attempt(
                              () => auth.savePreferences(
                                notificationsEnabled: value,
                              ),
                            ),
                          ),
                        ),
                        divider,
                        SettingsRow(
                          icon: LucideIcons.globe,
                          iconColor: GeneralColors.successColor,
                          iconBackground: GeneralColors.successSoftColor,
                          title: l10n.profileLanguage,
                          value: isEnglish
                              ? l10n.languageEnglish
                              : l10n.languageMongolian,
                          onTap: () => _chooseLanguage(user),
                        ),
                        divider,
                        SettingsRow(
                          icon: LucideIcons.shield,
                          iconColor: GeneralColors.anonymousColor,
                          iconBackground: GeneralColors.anonymousSoftColor,
                          title: l10n.profilePrivacy,
                          subtitle: l10n.profilePrivacySubtitle,
                          onTap: () => _showInfo(
                            l10n.profilePrivacy,
                            l10n.profilePrivacyBody,
                          ),
                        ),
                        divider,
                        SettingsRow(
                          icon: LucideIcons.circleQuestionMark,
                          iconColor: GeneralColors.warningTextColor,
                          iconBackground: GeneralColors.warningSoftColor,
                          title: l10n.profileHelp,
                          onTap: () =>
                              _showInfo(l10n.profileHelp, l10n.profileHelpBody),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              VSpacer(size: 12),
              OutlinedButton.icon(
                onPressed: _confirmSignOut,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: GeneralColors.cardColor,
                  foregroundColor: GeneralColors.dangerColor,
                  side: const BorderSide(color: GeneralColors.dangerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: Text(
                  l10n.profileSignOut,
                  style: GeneralTextStyle.sectionText(
                    textColor: GeneralColors.dangerColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});

  final String value, label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GeneralTextStyle.titleText(
                fontSize: 18,
                textColor: valueColor,
              ),
            ),
          ),
          VSpacer.xs(),
          Text(label, style: GeneralTextStyle.captionText(height: 1.25)),
        ],
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.initial});

  final String initial;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _controller.text.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.profileEditName, style: GeneralTextStyle.sectionText()),
            VSpacer(size: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 60,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.authNameLabel,
                counterText: '',
              ),
            ),
            VSpacer(size: 12),
            PrimaryButton(
              title: l10n.purchasesSave,
              isEnable: name.isNotEmpty,
              disabledColor: GeneralColors.borderColor,
              onPressed: () => Navigator.of(context).pop(name),
            ),
          ],
        ),
      ),
    );
  }
}
