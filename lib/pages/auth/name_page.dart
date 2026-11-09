import 'package:flutter/material.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/shared/components/icon_box.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Asked once, right after sign-up, so others can recognise this resident.
class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().saveName(_controller.text.trim());
    } catch (_) {
      if (mounted) Toast.error(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const IconBox(
                  icon: LucideIcons.user,
                  backgroundColor: GeneralColors.primarySoftColor,
                  iconColor: GeneralColors.primaryColor,
                ),
                VSpacer.lg(),
                Text(
                  l10n.authNameTitle,
                  style: GeneralTextStyle.titleText(fontSize: 28, height: 1.2),
                ),
                VSpacer.sm(),
                Text(
                  l10n.authNameSubtitle,
                  style: GeneralTextStyle.bodyText(
                    fontSize: 14.5,
                    textColor: GeneralColors.mutedColor,
                    height: 1.5,
                  ),
                ),
                VSpacer.xl(),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.authNameLabel,
                    counterText: '',
                  ),
                ),
                const Spacer(),
                VSpacer.lg(),
                PrimaryButton(
                  height: 56,
                  title: l10n.authContinue,
                  isEnable: !_saving && _controller.text.trim().isNotEmpty,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
