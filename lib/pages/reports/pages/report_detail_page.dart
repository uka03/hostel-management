import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/components/choice_pill.dart';
import 'package:hostel/pages/reports/components/report_card.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/provider/report_text.dart';
import 'package:hostel/pages/reports/provider/reports_provider.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/components/app_badge.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:provider/provider.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key, required this.reportId});

  final String reportId;

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
    final report = provider.byId(reportId);
    final isManager =
        context.select<AuthProvider, UserRole?>((a) => a.user?.role) ==
        UserRole.manager;

    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: report == null
          ? const Align(alignment: Alignment.topLeft, child: AppBackButton())
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                VSpacer.md(),
                Row(
                  children: [
                    AppBadge(
                      label: l10n.reportCategory(report.category),
                      color: GeneralColors.mutedColor,
                      backgroundColor: GeneralColors.borderColor,
                    ),
                    const Spacer(),
                    Text(
                      l10n.reportAgeLabel(
                        reportAge(report.createdAt, DateTime.now()),
                      ),
                      style: GeneralTextStyle.captionText(),
                    ),
                  ],
                ),
                VSpacer(size: 12),
                Text(report.location, style: GeneralTextStyle.sectionText()),
                VSpacer.sm(),
                Text(
                  report.description,
                  style: GeneralTextStyle.bodyText(fontSize: 15, height: 1.45),
                ),
                if (report.hasPhoto) ...[
                  VSpacer.md(),
                  _ReportPhoto(reportId: report.id),
                ],
                VSpacer.md(),
                Row(
                  children: [
                    const AnonymousAuthorIcon(),
                    HSpacer.xs(),
                    Expanded(
                      child: Text(
                        l10n.reportsAnonymousAuthor,
                        style: GeneralTextStyle.captionText(),
                      ),
                    ),
                    HSpacer.sm(),
                    ReportStatusBadge(status: report.status),
                    HSpacer.sm(),
                    VoteButton(
                      count: report.voteCount,
                      voted: report.voted,
                      onTap: provider.busy
                          ? null
                          : () => _vote(context, report),
                    ),
                  ],
                ),
                if (report.reply case final reply? when !isManager) ...[
                  VSpacer.md(),
                  AppCard(
                    child: Text(
                      l10n.reportsManagerReply(reply),
                      style: GeneralTextStyle.bodyText(height: 1.4),
                    ),
                  ),
                ],
                if (isManager) ...[
                  VSpacer.lg(),
                  _ManagerPanel(key: ValueKey(report.id), report: report),
                ],
              ],
            ),
    );
  }
}

class _ReportPhoto extends StatefulWidget {
  const _ReportPhoto({required this.reportId});

  final String reportId;

  @override
  State<_ReportPhoto> createState() => _ReportPhotoState();
}

class _ReportPhotoState extends State<_ReportPhoto> {
  late final Future<Uint8List> _photo = context.read<ReportsProvider>().photo(
    widget.reportId,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _photo,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return SizedBox(
            height: 160,
            child: Center(
              child: snapshot.hasError
                  ? Text(
                      AppLocalizations.of(context).reportsPhotoFailed,
                      style: GeneralTextStyle.captionText(),
                    )
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(data, width: double.infinity, fit: BoxFit.cover),
        );
      },
    );
  }
}

/// Status and reply. The manager sees nothing about who wrote the report.
class _ManagerPanel extends StatefulWidget {
  const _ManagerPanel({super.key, required this.report});

  final Report report;

  @override
  State<_ManagerPanel> createState() => _ManagerPanelState();
}

class _ManagerPanelState extends State<_ManagerPanel> {
  late ReportStatus _status = widget.report.status;
  late final _reply = TextEditingController(text: widget.report.reply ?? '');

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    try {
      await context.read<ReportsProvider>().update(
        widget.report,
        _status,
        _reply.text,
      );
      if (mounted) Toast.success(context, description: l10n.reportsSaved);
    } catch (_) {
      if (mounted) Toast.error(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = context.select<ReportsProvider, bool>((p) => p.busy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.reportsManagerTitle, style: GeneralTextStyle.sectionText()),
        VSpacer.sm(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in ReportStatus.values)
              ChoicePill(
                label: l10n.reportStatus(status),
                isSelected: _status == status,
                onTap: () => setState(() => _status = status),
              ),
          ],
        ),
        VSpacer(size: 12),
        TextField(
          controller: _reply,
          minLines: 2,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: l10n.reportsReplyHint,
            counterText: '',
          ),
        ),
        VSpacer(size: 12),
        PrimaryButton(
          title: l10n.cleaningSave,
          isEnable: !busy,
          onPressed: _save,
        ),
      ],
    );
  }
}
