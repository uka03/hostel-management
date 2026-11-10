import 'package:flutter/material.dart';
import 'package:hostel/connection/cleaning_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/components/area_duty_card.dart';
import 'package:hostel/pages/cleaning/components/cleaning_progress_card.dart';
import 'package:hostel/pages/cleaning/components/duty_status_badge.dart';
import 'package:hostel/pages/cleaning/components/period_strip.dart';
import 'package:hostel/pages/cleaning/components/swap_request_card.dart';
import 'package:hostel/pages/cleaning/components/weekday_labels.dart';
import 'package:hostel/pages/cleaning/pages/manage_cleaning_page.dart';
import 'package:hostel/pages/cleaning/provider/cleaning_provider.dart';
import 'package:hostel/pages/cleaning/provider/rotation.dart';
import 'package:hostel/shared/components/app_badge.dart';
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

class CleaningPage extends StatelessWidget {
  const CleaningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CleaningProvider(CleaningApi(context.read<DioClient>().dio)),
      child: ReloadWhenVisible(
        onVisible: (context) => context.read<CleaningProvider>().load(),
        child: const _CleaningView(),
      ),
    );
  }
}

class _CleaningView extends StatelessWidget {
  const _CleaningView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CleaningProvider>();
    final user = context.select<AuthProvider, UserResponseData?>((a) => a.user);
    final overview = provider.overview;
    final rotation = provider.rotation;
    final isManager = user?.role == UserRole.manager;

    final Widget body;
    if (overview == null) {
      body = provider.failed
          ? _LoadFailed(onRetry: provider.load)
          : const Center(child: CircularProgressIndicator());
    } else if (rotation != null &&
        rotation.personAt(provider.currentPeriod!) != null) {
      body = _Schedule(
        rotation: rotation,
        overview: overview,
        current: provider.currentPeriod!,
        meId: user?.id,
        isManager: isManager,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(
            isManager: isManager,
            pendingCount: overview.pendingResidents.length,
          ),
          VSpacer(size: 96),
          EmptyState(title: l10n.cleaningNotStarted),
        ],
      );
    }

    return Scaffold(
      backgroundColor: GeneralColors.backgroundColor,
      body: SafeArea(bottom: false, child: body),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmptyState(title: l10n.cleaningLoadFailed),
          VSpacer.md(),
          PrimaryButton(title: l10n.cleaningRetry, onPressed: onRetry),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CustomButton(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: GeneralColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GeneralColors.borderColor),
          ),
          child: Icon(icon, size: 20, color: GeneralColors.textColor),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isManager,
    required this.pendingCount,
    this.subtitle,
    this.onCalendar,
  });

  final bool isManager;
  final int pendingCount;
  final String? subtitle;
  final VoidCallback? onCalendar;

  void _openManage(BuildContext context) {
    final provider = context.read<CleaningProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const ManageCleaningPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cleaningTitle,
                style: GeneralTextStyle.titleText(height: 1.2),
              ),
              if (subtitle case final subtitle?) ...[
                VSpacer.xs(),
                Text(
                  subtitle,
                  style: GeneralTextStyle.bodyText(
                    textColor: GeneralColors.mutedColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isManager) ...[
          HSpacer.sm(),
          Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            backgroundColor: GeneralColors.dangerColor,
            child: _HeaderButton(
              icon: LucideIcons.settings2,
              tooltip: l10n.cleaningManageTitle,
              onTap: () => _openManage(context),
            ),
          ),
        ],
        if (onCalendar case final onCalendar?) ...[
          HSpacer.sm(),
          _HeaderButton(
            icon: LucideIcons.calendar,
            tooltip: l10n.cleaningUpcomingTitle,
            onTap: onCalendar,
          ),
        ],
      ],
    );
  }
}

class _Schedule extends StatefulWidget {
  const _Schedule({
    required this.rotation,
    required this.overview,
    required this.current,
    required this.meId,
    required this.isManager,
  });

  final Rotation rotation;
  final CleaningOverview overview;
  final int current;
  final String? meId;
  final bool isManager;

  @override
  State<_Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<_Schedule> {
  static const _stripLength = 7;

  /// The period picked in the strip; null follows the current one.
  int? _picked;

  Rotation get _rotation => widget.rotation;
  CleaningOverview get _overview => widget.overview;
  int get _current => widget.current;
  String? get _meId => widget.meId;

  int get _selected {
    final picked = _picked;
    final inRange =
        picked != null &&
        picked >= _current &&
        picked < _current + _stripLength;
    return inRange ? picked : _current;
  }

  /// The date a period is shown under: today for the current one.
  DateTime _dateOf(int period) =>
      period == _current ? _overview.today : _rotation.firstDayOf(period);

  String _nameOf(AppLocalizations l10n, String? id) {
    if (id != null && id == _meId) return l10n.cleaningYou;
    for (final member in _overview.members) {
      if (member.id == id) return member.name ?? l10n.cleaningUnnamed;
    }
    return l10n.cleaningUnnamed;
  }

  /// Runs a change, showing a toast if the server refuses it.
  Future<void> _attempt(
    Future<void> Function() change, {
    String? success,
  }) async {
    try {
      await change();
      if (mounted && success != null) {
        Toast.success(context, description: success);
      }
    } catch (_) {
      if (mounted) Toast.error(context);
    }
  }

  /// The duty this resident could still swap: the current one if it hasn't
  /// been started, otherwise their next turn.
  int? get _swappablePeriod {
    final me = _meId;
    if (me == null) return null;
    if (_rotation.personAt(_current) == me &&
        _overview.checkedAreaIds.isEmpty) {
      return _current;
    }
    return _rotation.nextTurnOf(me, after: _current);
  }

  Future<void> _showSwapSheet(int myPeriod) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<CleaningProvider>();
    final options = [
      for (var p = _current + 1; p <= _current + _stripLength; p++)
        if (p != myPeriod &&
            _rotation.personAt(p) != null &&
            _rotation.personAt(p) != _meId)
          p,
    ];
    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: GeneralColors.cardColor,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.cleaningSwapSheetTitle,
              style: GeneralTextStyle.sectionText(),
            ),
            VSpacer.xs(),
            Text(
              l10n.cleaningSwapSheetBody(_rotation.datesOf(myPeriod)),
              style: GeneralTextStyle.captionText(),
            ),
            VSpacer.sm(),
            for (final period in options)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(sheet).pop(period),
                child: _PeriodRow(
                  name: _nameOf(l10n, _rotation.personAt(period)),
                  dates: _rotation.datesOf(period),
                ),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    await _attempt(
      () => provider.requestSwap(myPeriod, chosen),
      success: l10n.cleaningSwapSent,
    );
  }

  void _showRotationSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GeneralColors.cardColor,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.cleaningUpcomingTitle,
              style: GeneralTextStyle.sectionText(),
            ),
            VSpacer.sm(),
            for (
              var p = _current > 0 ? _current - 1 : 0;
              p <= _current + _stripLength;
              p++
            )
              if (_rotation.personAt(p) != null)
                _PeriodRow(
                  name: _nameOf(l10n, _rotation.personAt(p)),
                  dates: _rotation.datesOf(p),
                  isMe: _rotation.personAt(p) == _meId,
                  status: p <= _current
                      ? _rotation.statusOf(p, current: _current)
                      : null,
                ),
          ],
        ),
      ),
    );
  }

  AreaCardState _stateOf({
    required bool isCurrent,
    required bool isChecked,
    required bool isMine,
  }) {
    if (!isCurrent) return AreaCardState.upcoming;
    if (isChecked) return AreaCardState.done;
    return isMine ? AreaCardState.yourTurn : AreaCardState.notDone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CleaningProvider>();
    final me = _meId;
    final selected = _selected;
    final isCurrent = selected == _current;
    final person = _rotation.personAt(selected);
    final isMine = me != null && person == me;
    final onDuty = me != null && _rotation.personAt(_current) == me;

    final checked = _overview.checkedAreaIds.toSet();
    final areas = _overview.areas;
    final doneCount = areas.where((a) => checked.contains(a.id)).length;
    final remaining = areas.where((a) => !checked.contains(a.id)).toList();
    final firstRemaining = isMine && isCurrent && remaining.isNotEmpty
        ? remaining.first.id
        : null;

    final nextTurn = me == null
        ? null
        : _rotation.nextTurnOf(me, after: _current);
    final swappable = _swappablePeriod;
    final canSwap =
        swappable != null &&
        !provider.busy &&
        !_overview.swaps.any(
          (s) => s.requesterPeriod == swappable || s.targetPeriod == swappable,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
                _Header(
                  isManager: widget.isManager,
                  pendingCount: _overview.pendingResidents.length,
                  subtitle:
                      '${_rotation.datesOf(_current)} · '
                      '${l10n.cleaningDaysLeft(_rotation.daysLeftOn(_overview.today))}',
                  onCalendar: _showRotationSheet,
                ),
                VSpacer.md(),
                PeriodStrip(
                  items: [
                    for (var i = 0; i < _stripLength; i++)
                      PeriodStripItem(
                        period: _current + i,
                        date: _dateOf(_current + i),
                        isMine:
                            me != null &&
                            _rotation.personAt(_current + i) == me,
                      ),
                  ],
                  selected: selected,
                  onSelected: (period) => setState(() => _picked = period),
                ),
                VSpacer.md(),
                for (final swap in _overview.swaps) ...[
                  _swapCard(l10n, provider, swap),
                  VSpacer.sm(),
                ],
                CleaningProgressCard(
                  done: doneCount,
                  total: areas.length,
                  nextTurn: nextTurn == null
                      ? null
                      : _rotation.datesOf(nextTurn),
                ),
                VSpacer.md(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.longDate(_dateOf(selected)),
                        style: GeneralTextStyle.sectionText(),
                      ),
                    ),
                    HSpacer.sm(),
                    AppBadge(
                      label: l10n.cleaningAreaCount(areas.length),
                      color: GeneralColors.mutedColor,
                      backgroundColor: GeneralColors.borderColor,
                    ),
                  ],
                ),
                VSpacer(size: 12),
                if (areas.isEmpty)
                  Text(
                    l10n.cleaningNoAreas,
                    style: GeneralTextStyle.captionText(),
                  ),
                for (final area in areas) ...[
                  AreaDutyCard(
                    name: area.name,
                    person: _nameOf(l10n, person),
                    state: _stateOf(
                      isCurrent: isCurrent,
                      isChecked: checked.contains(area.id),
                      isMine: isMine,
                    ),
                    isHighlighted: area.id == firstRemaining,
                    onTap: isMine && isCurrent && !provider.busy
                        ? () => _attempt(
                            () => provider.setAreaChecked(
                              area.id,
                              !checked.contains(area.id),
                            ),
                          )
                        : null,
                  ),
                  VSpacer.sm(),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  backgroundColor: GeneralColors.primarySoftColor,
                  disabledColor: GeneralColors.borderColor,
                  isEnable: canSwap,
                  onPressed: () => _showSwapSheet(swappable!),
                  content: _ButtonLabel(
                    icon: LucideIcons.repeat,
                    label: l10n.cleaningSwapAction,
                    color: canSwap
                        ? GeneralColors.primaryColor
                        : GeneralColors.mutedColor,
                  ),
                ),
              ),
              if (onDuty) ...[
                HSpacer.sm(),
                Expanded(
                  child: PrimaryButton(
                    disabledColor: GeneralColors.borderColor,
                    isEnable: remaining.isNotEmpty && !provider.busy,
                    onPressed: () => _attempt(
                      () => provider.completeAreas([
                        for (final area in remaining) area.id,
                      ]),
                    ),
                    content: _ButtonLabel(
                      icon: LucideIcons.check,
                      label: l10n.cleaningFinish,
                      color: remaining.isNotEmpty
                          ? GeneralColors.onPrimaryColor
                          : GeneralColors.mutedColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _swapCard(
    AppLocalizations l10n,
    CleaningProvider provider,
    DutySwap swap,
  ) {
    final enabled = !provider.busy;
    if (swap.targetId == _meId) {
      return SwapRequestCard(
        message: l10n.cleaningSwapIncoming(
          _nameOf(l10n, swap.requesterId),
          _rotation.datesOf(swap.targetPeriod),
          _rotation.datesOf(swap.requesterPeriod),
        ),
        primaryLabel: l10n.cleaningAccept,
        onPrimary: enabled
            ? () => _attempt(() => provider.respondSwap(swap.id, true))
            : null,
        secondaryLabel: l10n.cleaningDecline,
        onSecondary: enabled
            ? () => _attempt(() => provider.respondSwap(swap.id, false))
            : null,
      );
    }
    return SwapRequestCard(
      message: l10n.cleaningSwapOutgoing(
        _nameOf(l10n, swap.targetId),
        _rotation.datesOf(swap.requesterPeriod),
        _rotation.datesOf(swap.targetPeriod),
      ),
      primaryLabel: l10n.cleaningCancelRequest,
      onPrimary: enabled
          ? () => _attempt(() => provider.cancelSwap(swap.id))
          : null,
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        HSpacer.sm(),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: GeneralTextStyle.sectionText(fontSize: 15, textColor: color),
          ),
        ),
      ],
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.name,
    required this.dates,
    this.status,
    this.isMe = false,
  });

  final String name, dates;
  final DutyStatus? status;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GeneralTextStyle.bodyText(
                textColor: isMe
                    ? GeneralColors.primaryColor
                    : GeneralColors.textColor,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (status case final status?) ...[
            DutyStatusBadge(status: status),
            HSpacer.sm(),
          ],
          Text(dates, style: GeneralTextStyle.captionText()),
        ],
      ),
    );
  }
}
