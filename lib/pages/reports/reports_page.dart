import 'package:flutter/material.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/connection/reports_api.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/components/choice_pill.dart';
import 'package:hostel/pages/reports/components/report_card.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/pages/report_detail_page.dart';
import 'package:hostel/pages/reports/pages/report_form_page.dart';
import 'package:hostel/pages/reports/provider/reports_provider.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/components/reload_when_visible.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/empty_state.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ReportsProvider(ReportsApi(context.read<DioClient>().dio)),
      child: ReloadWhenVisible(
        onVisible: (context) => context.read<ReportsProvider>().load(),
        child: const _ReportsView(),
      ),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  void _open(BuildContext context, Widget page) {
    final provider = context.read<ReportsProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChangeNotifierProvider.value(value: provider, child: page),
      ),
    );
  }

  Future<void> _vote(BuildContext context, Report report) async {
    try {
      await context.read<ReportsProvider>().toggleVote(report);
    } catch (_) {
      if (context.mounted) Toast.error(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReportsProvider>();
    final reports = provider.visible;
    final now = DateTime.now();

    final Widget content;
    if (provider.failed) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VSpacer(size: 64),
          EmptyState(title: l10n.reportsLoadFailed),
          VSpacer.md(),
          PrimaryButton(title: l10n.cleaningRetry, onPressed: provider.load),
        ],
      );
    } else if (!provider.isLoaded) {
      content = const Padding(
        padding: EdgeInsets.only(top: 96),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (reports.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.only(top: 64),
        child: EmptyState(title: l10n.reportsEmpty),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final report in reports) ...[
            ReportCard(
              report: report,
              now: now,
              onTap: () =>
                  _open(context, ReportDetailPage(reportId: report.id)),
              onVote: provider.busy ? null : () => _vote(context, report),
            ),
            VSpacer.sm(),
          ],
        ],
      );
    }

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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tabReports,
                          style: GeneralTextStyle.titleText(),
                        ),
                        VSpacer(size: 2),
                        Text(
                          l10n.reportsSubtitle,
                          style: GeneralTextStyle.bodyText(
                            textColor: GeneralColors.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HSpacer.sm(),
                  Tooltip(
                    message: l10n.reportsFormTitle,
                    child: CustomButton(
                      onTap: () => _open(context, const ReportFormPage()),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoicePill(
                      label: l10n.reportsFilterAll,
                      isSelected: provider.filter == null,
                      selectedColor: GeneralColors.darkCardColor,
                      onTap: () => provider.setFilter(null),
                    ),
                    for (final status in ReportStatus.values) ...[
                      HSpacer.sm(),
                      ChoicePill(
                        label: l10n.reportStatus(status),
                        isSelected: provider.filter == status,
                        selectedColor: GeneralColors.darkCardColor,
                        onTap: () => provider.setFilter(status),
                      ),
                    ],
                  ],
                ),
              ),
              VSpacer.md(),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
