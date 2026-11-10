import 'package:flutter/material.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/extensions/int_extensions.dart';
import 'package:hostel/connection/purchases_api.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/components/needed_items_card.dart';
import 'package:hostel/pages/purchases/components/purchase_row.dart';
import 'package:hostel/pages/purchases/components/purchase_sheets.dart';
import 'package:hostel/pages/purchases/components/purchases_hero_card.dart';
import 'package:hostel/pages/purchases/pages/all_purchases_page.dart';
import 'package:hostel/pages/purchases/provider/purchases_provider.dart';
import 'package:hostel/pages/purchases/provider/split.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/components/reload_when_visible.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/empty_state.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PurchasesProvider(PurchasesApi(context.read<DioClient>().dio)),
      child: ReloadWhenVisible(
        onVisible: (context) => context.read<PurchasesProvider>().load(),
        child: const _PurchasesView(),
      ),
    );
  }
}

class _PurchasesView extends StatelessWidget {
  const _PurchasesView();

  Future<void> _attempt(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    try {
      await change();
    } catch (_) {
      if (context.mounted) Toast.error(context);
    }
  }

  Future<void> _add(BuildContext context, PurchasesOverview overview) async {
    final provider = context.read<PurchasesProvider>();
    final choice = await showAddChoiceSheet(context);
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case AddChoice.purchase:
        final result = await showAddPurchaseSheet(
          context,
          people: overview.activeCount,
        );
        if (result != null && context.mounted) {
          await _attempt(
            context,
            () => provider.addPurchase(result.title, result.amount),
          );
        }
      case AddChoice.item:
        final name = await showAddItemSheet(context);
        if (name != null && context.mounted) {
          await _attempt(context, () => provider.addItem(name));
        }
    }
  }

  Future<void> _receipt(
    BuildContext context,
    PurchasesOverview overview,
    NeededItem item,
  ) async {
    final provider = context.read<PurchasesProvider>();
    final result = await showReceiptSheet(
      context,
      item: item,
      people: overview.activeCount,
    );
    if (result == null || !context.mounted) return;
    final amount = result.amount;
    await _attempt(
      context,
      () => amount == null
          ? provider.unclaimItem(item.id)
          : provider.completeItem(item.id, amount),
    );
  }

  void _openHistory(BuildContext context) {
    final provider = context.read<PurchasesProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const AllPurchasesPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<PurchasesProvider>();
    final user = context.select<AuthProvider, UserResponseData?>((a) => a.user);
    final overview = provider.overview;

    final Widget body;
    if (overview == null) {
      body = provider.failed
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmptyState(title: l10n.purchasesLoadFailed),
                  VSpacer.md(),
                  PrimaryButton(
                    title: l10n.cleaningRetry,
                    onPressed: provider.load,
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      // Others' purchases I share in and haven't paid the buyer for yet.
      final unpaid = overview.purchases
          .where((p) => p.myShare != null && p.buyerId != user?.id && !p.myPaid)
          .toList();
      final owed = unpaid.fold(0, (sum, p) => sum + p.myShare!);
      body = RefreshIndicator(
        onRefresh: provider.load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.purchasesTitle,
                        style: GeneralTextStyle.titleText(height: 1.2),
                      ),
                      VSpacer(size: 2),
                      Text(
                        l10n.purchasesSubtitle(overview.activeCount),
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                HSpacer.sm(),
                Tooltip(
                  message: l10n.purchasesHistoryTitle,
                  child: CustomButton(
                    onTap: () => _openHistory(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GeneralColors.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: GeneralColors.borderColor),
                      ),
                      child: const Icon(
                        LucideIcons.history,
                        size: 22,
                        color: GeneralColors.textColor,
                      ),
                    ),
                  ),
                ),
                HSpacer.sm(),
                Tooltip(
                  message: l10n.purchasesAddPurchase,
                  child: CustomButton(
                    onTap: () => _add(context, overview),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GeneralColors.primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        size: 22,
                        color: GeneralColors.onPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            VSpacer.md(),
            PurchasesHeroCard(
              summary: BalanceSummary(
                total: overview.totalAmount,
                paid: overview.myPaid,
                share: overview.myShare,
              ),
            ),
            VSpacer.lg(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.purchasesNeededTitle,
                    style: GeneralTextStyle.sectionText(),
                  ),
                ),
                if (overview.neededItems.isNotEmpty)
                  AppBadge(
                    label: '${overview.neededItems.length}',
                    color: GeneralColors.warningColor,
                    backgroundColor: GeneralColors.warningSoftColor,
                  ),
              ],
            ),
            VSpacer(size: 12),
            NeededItemsCard(
              items: overview.neededItems,
              today: overview.today,
              meId: user?.id,
              isManager: user?.role == UserRole.manager,
              enabled: !provider.busy,
              onClaim: (item) =>
                  _attempt(context, () => provider.claimItem(item.id)),
              onReceipt: (item) => _receipt(context, overview, item),
              onRemove: (item) =>
                  _attempt(context, () => provider.removeItem(item.id)),
            ),
            VSpacer.lg(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.purchasesUnpaidTitle,
                    style: GeneralTextStyle.sectionText(),
                  ),
                ),
                if (owed > 0)
                  AppBadge(
                    label: owed.toMnt(),
                    color: GeneralColors.warningColor,
                    backgroundColor: GeneralColors.warningSoftColor,
                  ),
              ],
            ),
            VSpacer(size: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: unpaid.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.purchasesUnpaidNone,
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.mutedColor,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final (index, purchase) in unpaid.indexed) ...[
                          if (index > 0)
                            const Divider(
                              height: 1,
                              color: GeneralColors.borderColor,
                            ),
                          PurchaseRow(purchase: purchase),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: GeneralColors.backgroundColor,
      body: SafeArea(bottom: false, child: body),
    );
  }
}
