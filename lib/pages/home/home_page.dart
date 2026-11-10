import 'package:flutter/material.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/connection/notifications_api.dart';
import 'package:hostel/connection/purchases_api.dart';
import 'package:hostel/connection/reports_api.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/components/weekday_labels.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';
import 'package:hostel/pages/home/components/activity_row.dart';
import 'package:hostel/pages/home/components/duty_card.dart';
import 'package:hostel/pages/home/pages/activity_page.dart';
import 'package:hostel/pages/home/pages/notifications_page.dart';
import 'package:hostel/pages/home/provider/home_provider.dart';
import 'package:hostel/pages/home/provider/home_summary.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/shared/components/reload_when_visible.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Tab positions in the main shell.
const _cleaningTab = 1, _purchasesTab = 2, _reportsTab = 3;

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<DioClient>().dio;
        return HomeProvider(
          CleaningApi(dio),
          PurchasesApi(dio),
          ReportsApi(dio),
          NotificationsApi(dio),
        );
      },
      child: ReloadWhenVisible(
        onVisible: (context) => context.read<HomeProvider>().load(),
        child: _HomeView(onOpenTab: onOpenTab),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({required this.onOpenTab});

  static const _previewCount = 3;

  final ValueChanged<int> onOpenTab;

  void _openActivity(BuildContext context) {
    final provider = context.read<HomeProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const ActivityPage(),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    final provider = context.read<HomeProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: NotificationsPage(onOpenTab: onOpenTab),
        ),
      ),
    );
  }

  Future<void> _completeDuty(BuildContext context) async {
    try {
      await context.read<HomeProvider>().completeDuty();
    } catch (_) {
      if (context.mounted) Toast.error(context);
    }
  }

  String _greeting(AppLocalizations l10n, DateTime now) =>
      switch (dayPartAt(now)) {
        DayPart.morning => l10n.homeGreetingMorning,
        DayPart.afternoon => l10n.homeGreetingAfternoon,
        DayPart.evening => l10n.homeGreetingEvening,
      };

  Widget _dutyCard(
    BuildContext context,
    AppLocalizations l10n,
    HomeProvider provider,
    String? meId,
  ) {
    final cleaning = provider.cleaning;
    final rotation = provider.rotation;
    final me = meId;
    final title = l10n.homeDutyTitle;

    DutyCard schedule({
      required String label,
      required String cardTitle,
      String? dateLine,
    }) => DutyCard(
      label: label,
      title: cardTitle,
      dateLine: dateLine,
      actionLabel: l10n.homeViewSchedule,
      actionIcon: LucideIcons.calendar,
      onAction: () => onOpenTab(_cleaningTab),
    );

    if (cleaning == null || rotation == null || me == null) {
      return schedule(
        label: l10n.homeNextDutyLabel,
        cardTitle: l10n.homeNoDuty,
      );
    }

    final current = rotation.periodOf(cleaning.today);
    if (rotation.personAt(current) == me) {
      final isDone =
          rotation.statusOf(current, current: current) == DutyStatus.done;
      return DutyCard(
        label: l10n.homeCurrentDutyLabel,
        title: title,
        dateLine:
            '${l10n.longDate(cleaning.today)} · '
            '${l10n.cleaningDaysLeft(rotation.daysLeftOn(cleaning.today))}',
        actionLabel: isDone ? l10n.cleaningFinish : l10n.homeMarkDone,
        actionIcon: LucideIcons.check,
        onAction: isDone || provider.busy || cleaning.areas.isEmpty
            ? null
            : () => _completeDuty(context),
      );
    }

    final next = rotation.nextTurnOf(me, after: current);
    if (next == null) {
      return schedule(
        label: l10n.homeNextDutyLabel,
        cardTitle: l10n.homeNoDuty,
      );
    }
    return schedule(
      label: l10n.homeNextDutyLabel,
      cardTitle: title,
      dateLine: l10n.longDate(rotation.firstDayOf(next)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    final user = context.select<AuthProvider, UserResponseData?>((a) => a.user);
    final now = DateTime.now();
    final cleaning = provider.cleaning;
    final purchases = provider.purchases;
    final today = cleaning?.today ?? purchases?.today ?? now;
    final activity = provider.activity;

    final checked = cleaning?.checkedAreaIds.toSet() ?? const <String>{};
    final openAreas =
        cleaning?.areas.where((a) => !checked.contains(a.id)).length ?? 0;
    final missingItems = purchases?.neededItems.length ?? 0;

    return Scaffold(
      backgroundColor: GeneralColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(l10n, now),
                          style: GeneralTextStyle.bodyText(
                            fontSize: 15,
                            textColor: GeneralColors.mutedColor,
                          ),
                        ),
                        VSpacer(size: 2),
                        Text(
                          user?.name ?? '',
                          style: GeneralTextStyle.titleText(fontSize: 28),
                        ),
                        VSpacer(size: 2),
                        Text(
                          l10n.profileApartment,
                          style: GeneralTextStyle.bodyText(
                            textColor: GeneralColors.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: l10n.notificationsTitle,
                    child: CustomButton(
                      onTap: () => _openNotifications(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Badge(
                        isLabelVisible: provider.unreadCount > 0,
                        label: Text(
                          provider.unreadCount > 9
                              ? '9+'
                              : '${provider.unreadCount}',
                        ),
                        backgroundColor: GeneralColors.dangerColor,
                        textColor: GeneralColors.onPrimaryColor,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: GeneralColors.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: GeneralColors.borderColor,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.bell,
                            size: 20,
                            color: GeneralColors.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              VSpacer.md(),
              _dutyCard(context, l10n, provider, user?.id),
              VSpacer.lg(),
              Text(l10n.homeQuickTitle, style: GeneralTextStyle.sectionText()),
              VSpacer(size: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: LucideIcons.sparkle,
                        color: GeneralColors.successColor,
                        background: GeneralColors.successSoftColor,
                        title: l10n.tabCleaning,
                        subtitle: l10n.cleaningAreaCount(openAreas),
                        onTap: () => onOpenTab(_cleaningTab),
                      ),
                    ),
                    HSpacer.sm(),
                    Expanded(
                      child: _QuickAction(
                        icon: LucideIcons.shoppingCart,
                        color: GeneralColors.warningColor,
                        background: GeneralColors.warningSoftColor,
                        title: l10n.tabPurchases,
                        subtitle: l10n.homeItemsMissing(missingItems),
                        onTap: () => onOpenTab(_purchasesTab),
                      ),
                    ),
                    HSpacer.sm(),
                    Expanded(
                      child: _QuickAction(
                        icon: LucideIcons.shield,
                        color: GeneralColors.anonymousColor,
                        background: GeneralColors.anonymousSoftColor,
                        title: l10n.homeReportAction,
                        subtitle: l10n.homeAnonymous,
                        onTap: () => onOpenTab(_reportsTab),
                      ),
                    ),
                  ],
                ),
              ),
              VSpacer.lg(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeActivityTitle,
                      style: GeneralTextStyle.sectionText(),
                    ),
                  ),
                  if (activity.length > _previewCount)
                    CustomButton(
                      onTap: () => _openActivity(context),
                      child: Text(
                        l10n.purchasesSeeAll,
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              VSpacer(size: 12),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: activity.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          l10n.homeNoActivity,
                          style: GeneralTextStyle.bodyText(
                            textColor: GeneralColors.mutedColor,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final (index, item)
                              in activity.take(_previewCount).indexed) ...[
                            if (index > 0)
                              const Divider(
                                height: 1,
                                color: GeneralColors.borderColor,
                              ),
                            ActivityRow(activity: item, today: today, now: now),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color, background;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBox(
              icon: icon,
              backgroundColor: background,
              iconColor: color,
              size: 36,
              iconSize: 18,
              radius: 10,
            ),
            VSpacer(size: 10),
            Text(title, style: GeneralTextStyle.sectionText(fontSize: 14)),
            VSpacer(size: 2),
            Text(subtitle, style: GeneralTextStyle.captionText()),
          ],
        ),
      ),
    );
  }
}
