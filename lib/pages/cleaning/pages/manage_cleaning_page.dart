import 'package:flutter/material.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/provider/cleaning_provider.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_app_bar.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Manager tools: approve residents, set the rotation, edit the areas.
class ManageCleaningPage extends StatefulWidget {
  const ManageCleaningPage({super.key});

  @override
  State<ManageCleaningPage> createState() => _ManageCleaningPageState();
}

class _ManageCleaningPageState extends State<ManageCleaningPage> {
  final _areaController = TextEditingController();

  /// Unsaved rotation edits; null while showing the saved order.
  List<String>? _draft;

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _attempt(Future<void> Function() change) async {
    try {
      await change();
    } catch (_) {
      if (mounted) Toast.error(context);
    }
  }

  List<String> _savedOrder(CleaningProvider provider) {
    final current = provider.currentPeriod;
    if (current == null) return const [];
    return provider.rotation!.sequenceAt(current + 1);
  }

  void _edit(CleaningProvider provider, void Function(List<String>) change) {
    setState(() {
      final draft = [...(_draft ?? _savedOrder(provider))];
      change(draft);
      _draft = draft;
    });
  }

  Future<void> _saveOrder(CleaningProvider provider) => _attempt(() async {
    await provider.setRotationOrder(_draft!);
    if (mounted) setState(() => _draft = null);
  });

  Future<void> _addArea(CleaningProvider provider) => _attempt(() async {
    final name = _areaController.text.trim();
    if (name.isEmpty) return;
    await provider.addArea(name);
    _areaController.clear();
  });

  Future<void> _confirmMoveOut(
    CleaningProvider provider,
    CleaningMember member,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.cleaningMoveOutTitle),
        content: Text(l10n.cleaningMoveOutBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cleaningCancelRequest),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              l10n.cleaningMoveOutConfirm,
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
    await _attempt(() async {
      await provider.removeResident(member.id);
      if (mounted) setState(() => _draft = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CleaningProvider>();
    final overview = provider.overview!;
    final meId = context
        .select<AuthProvider, UserResponseData?>((a) => a.user)
        ?.id;
    final order = _draft ?? _savedOrder(provider);
    final membersById = {for (final m in overview.members) m.id: m};
    final notInRotation = overview.members
        .where((m) => m.active && !order.contains(m.id))
        .toList();
    String nameOf(CleaningMember? m) => m?.name ?? l10n.cleaningUnnamed;
    final enabled = !provider.busy;

    return GeneralScaffold(
      padding: EdgeInsets.zero,
      bottom: false,
      appBar: CustomAppBar(
        bgColor: GeneralColors.backgroundColor,
        title: Text(
          l10n.cleaningManageTitle,
          style: GeneralTextStyle.sectionText(),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (overview.pendingResidents.isNotEmpty) ...[
            _SectionTitle(l10n.cleaningManagePending),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (final resident in overview.pendingResidents)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resident.name ?? l10n.cleaningUnnamed,
                            style: GeneralTextStyle.bodyText(),
                          ),
                        ),
                        TextButton(
                          onPressed: enabled
                              ? () => _attempt(
                                  () => provider.removeResident(resident.id),
                                )
                              : null,
                          child: Text(
                            l10n.cleaningDecline,
                            style: GeneralTextStyle.bodyText(
                              textColor: GeneralColors.mutedColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: enabled
                              ? () => _attempt(() async {
                                  await provider.approveResident(resident.id);
                                  if (mounted) setState(() => _draft = null);
                                })
                              : null,
                          child: Text(
                            l10n.cleaningAccept,
                            style: GeneralTextStyle.bodyText(
                              textColor: GeneralColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            VSpacer.lg(),
          ],
          _SectionTitle(l10n.cleaningManageOrder),
          Text(
            l10n.cleaningManageOrderHint,
            style: GeneralTextStyle.captionText(),
          ),
          VSpacer.sm(),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: (from, to) => _edit(provider, (draft) {
                draft.insert(to, draft.removeAt(from));
              }),
              children: [
                for (final (index, id) in order.indexed)
                  Row(
                    key: ValueKey(id),
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            LucideIcons.gripVertical,
                            size: 18,
                            color: GeneralColors.mutedColor,
                          ),
                        ),
                      ),
                      HSpacer.xs(),
                      Expanded(
                        child: Text(
                          nameOf(membersById[id]),
                          style: GeneralTextStyle.bodyText(),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.cleaningRemoveFromRotation,
                        onPressed: () =>
                            _edit(provider, (draft) => draft.remove(id)),
                        icon: const Icon(
                          LucideIcons.circleMinus,
                          size: 18,
                          color: GeneralColors.mutedColor,
                        ),
                      ),
                      if (id != meId && membersById[id] != null)
                        IconButton(
                          tooltip: l10n.cleaningMoveOutTitle,
                          onPressed: enabled
                              ? () => _confirmMoveOut(
                                  provider,
                                  membersById[id]!,
                                  nameOf(membersById[id]),
                                )
                              : null,
                          icon: const Icon(
                            LucideIcons.userX,
                            size: 18,
                            color: GeneralColors.dangerColor,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          for (final member in notInRotation)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        nameOf(member),
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.mutedColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _edit(provider, (draft) => draft.add(member.id)),
                      child: Text(
                        l10n.cleaningAddToRotation,
                        style: GeneralTextStyle.bodyText(
                          textColor: GeneralColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_draft != null) ...[
            VSpacer.md(),
            PrimaryButton(
              title: l10n.cleaningSave,
              isEnable: enabled,
              onPressed: () => _saveOrder(provider),
            ),
          ],
          VSpacer.lg(),
          _SectionTitle(l10n.cleaningAreasTitle),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (final area in overview.areas)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          area.name,
                          style: GeneralTextStyle.bodyText(),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.cleaningRemoveArea,
                        onPressed: enabled
                            ? () => _attempt(() => provider.removeArea(area.id))
                            : null,
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: GeneralColors.mutedColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          VSpacer.sm(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _areaController,
                  maxLength: 60,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addArea(provider),
                  decoration: InputDecoration(
                    hintText: l10n.cleaningNewAreaHint,
                    counterText: '',
                  ),
                ),
              ),
              HSpacer.sm(),
              Tooltip(
                message: l10n.cleaningAddToRotation,
                child: CustomButton(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (enabled) _addArea(provider);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: GeneralColors.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      LucideIcons.plus,
                      size: 20,
                      color: GeneralColors.onPrimaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GeneralTextStyle.sectionText()),
    );
  }
}
