import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/home/components/activity_row.dart';
import 'package:hostel/pages/home/provider/home_provider.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/empty_state.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    final activity = provider.activity;
    final now = DateTime.now();
    final today = provider.cleaning?.today ?? provider.purchases?.today ?? now;

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
                  l10n.homeActivityTitle,
                  style: GeneralTextStyle.titleText(fontSize: 20),
                ),
              ),
            ],
          ),
          VSpacer.sm(),
          Expanded(
            child: activity.isEmpty
                ? EmptyState(title: l10n.homeNoActivity)
                : ListView.separated(
                    itemCount: activity.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: GeneralColors.borderColor,
                    ),
                    itemBuilder: (_, index) => ActivityRow(
                      activity: activity[index],
                      today: today,
                      now: now,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
