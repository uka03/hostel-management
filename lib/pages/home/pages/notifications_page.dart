import 'package:flutter/material.dart';
import 'package:hostel/connection/model/app_notification.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/home/components/notification_row.dart';
import 'package:hostel/pages/home/provider/home_provider.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/empty_state.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:provider/provider.dart';

/// Tab positions in the main shell.
const _purchasesTab = 2, _reportsTab = 3;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Seen once opened. New ones stay marked until the list next loads.
    context.read<HomeProvider>().markNotificationsRead();
  }

  void _open(AppNotification notification) {
    final tab = switch (notification.kind) {
      NotificationKind.paid || NotificationKind.newPurchase => _purchasesTab,
      NotificationKind.reportNew ||
      NotificationKind.reportUpdate => _reportsTab,
      NotificationKind.other => null,
    };
    if (tab == null) return;
    Navigator.of(context).pop();
    widget.onOpenTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    final items = provider.notifications;
    final now = DateTime.now();

    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppBackButton(),
              HSpacer(size: 12),
              Expanded(
                child: Text(
                  l10n.notificationsTitle,
                  style: GeneralTextStyle.titleText(fontSize: 20),
                ),
              ),
            ],
          ),
          VSpacer.sm(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadNotifications,
              child: items.isEmpty
                  ? ListView(
                      children: [
                        VSpacer(size: 64),
                        EmptyState(title: l10n.notificationsEmpty),
                      ],
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: GeneralColors.borderColor,
                      ),
                      itemBuilder: (_, index) => NotificationRow(
                        notification: items[index],
                        now: now,
                        onTap: () => _open(items[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
