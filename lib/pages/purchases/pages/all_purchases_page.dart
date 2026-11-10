import 'package:flutter/material.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/components/purchase_row.dart';
import 'package:hostel/pages/purchases/provider/purchases_provider.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class AllPurchasesPage extends StatelessWidget {
  const AllPurchasesPage({super.key});

  Future<void> _confirmDelete(BuildContext context, Purchase purchase) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<PurchasesProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.purchasesDeleteTitle),
        content: Text(l10n.purchasesDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cleaningCancelRequest),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              l10n.cleaningRemoveArea,
              style: GeneralTextStyle.bodyText(
                textColor: GeneralColors.dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await provider.deletePurchase(purchase.id);
    } catch (_) {
      if (context.mounted) Toast.error(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<PurchasesProvider>();
    final user = context.select<AuthProvider, UserResponseData?>((a) => a.user);
    final purchases = provider.overview?.purchases ?? const <Purchase>[];
    final isManager = user?.role == UserRole.manager;

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
                  l10n.purchasesHistoryTitle,
                  style: GeneralTextStyle.titleText(fontSize: 20),
                ),
              ),
            ],
          ),
          VSpacer.sm(),
          if (purchases.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.purchasesNoRecent,
                style: GeneralTextStyle.bodyText(
                  textColor: GeneralColors.mutedColor,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: purchases.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: GeneralColors.borderColor),
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                final canDelete = isManager || purchase.buyerId == user?.id;
                return PurchaseRow(
                  purchase: purchase,
                  trailing: canDelete
                      ? IconButton(
                          tooltip: l10n.cleaningRemoveArea,
                          onPressed: provider.busy
                              ? null
                              : () => _confirmDelete(context, purchase),
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: GeneralColors.mutedColor,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
