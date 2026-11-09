import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/components/choice_pill.dart';
import 'package:hostel/pages/reports/components/report_labels.dart';
import 'package:hostel/pages/reports/provider/photo_sanitizer.dart';
import 'package:hostel/pages/reports/provider/reports_provider.dart';
import 'package:hostel/shared/components/app_back_button.dart';
import 'package:hostel/shared/components/app_card.dart';
import 'package:hostel/shared/components/custom_button.dart';
import 'package:hostel/shared/components/primary_button.dart';
import 'package:hostel/shared/general_scaffold.dart';
import 'package:hostel/utils/colors.dart';
import 'package:hostel/utils/spacer.dart';
import 'package:hostel/utils/text_styles.dart';
import 'package:hostel/utils/toasts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  static const _maxDescription = 500;

  final _description = TextEditingController();
  ReportCategory? _category;
  String _location = '';
  Uint8List? _photo;
  bool _preparingPhoto = false;
  bool _sending = false;

  bool get _canSend =>
      _category != null &&
      _location.isNotEmpty &&
      _description.text.trim().isNotEmpty &&
      !_preparingPhoto &&
      !_sending;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _editLocation() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: _location);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GeneralColors.cardColor,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheet).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reportsLocationLabel,
              style: GeneralTextStyle.sectionText(),
            ),
            VSpacer(size: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 80,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => Navigator.of(sheet).pop(value),
              decoration: InputDecoration(
                hintText: l10n.reportsLocationHint,
                counterText: '',
              ),
            ),
            VSpacer(size: 12),
            PrimaryButton(
              title: l10n.cleaningSave,
              onPressed: () => Navigator.of(sheet).pop(controller.text),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _location = result.trim());
    }
  }

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: GeneralColors.cardColor,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l10n.reportsPhotoCamera),
              onTap: () => Navigator.of(sheet).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l10n.reportsPhotoGallery),
              onTap: () => Navigator.of(sheet).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _preparingPhoto = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (picked == null) return;
      final clean = await compute(
        sanitizeReportPhoto,
        await picked.readAsBytes(),
      );
      if (mounted) setState(() => _photo = clean);
    } catch (_) {
      if (mounted) Toast.error(context, description: l10n.reportsPhotoFailed);
    } finally {
      if (mounted) setState(() => _preparingPhoto = false);
    }
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final category = _category;
    if (category == null) return;
    setState(() => _sending = true);
    try {
      await context.read<ReportsProvider>().create(
        category: category,
        location: _location,
        description: _description.text.trim(),
        cleanPhoto: _photo,
      );
      if (!mounted) return;
      Toast.success(context, description: l10n.reportsSent);
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      Toast.error(
        context,
        description: e.response?.statusCode == 429
            ? l10n.reportsRateLimited
            : null,
      );
    } catch (_) {
      if (mounted) Toast.error(context);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GeneralScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppBackButton(),
              HSpacer(size: 12),
              Expanded(
                child: Text(
                  l10n.reportsFormTitle,
                  style: GeneralTextStyle.titleText(),
                ),
              ),
            ],
          ),
          VSpacer.md(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AnonymityBanner(),
                  VSpacer.md(),
                  _Label(l10n.reportsCategoryLabel),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in ReportCategory.values)
                        ChoicePill(
                          label: l10n.reportCategory(category),
                          isSelected: _category == category,
                          onTap: () => setState(() => _category = category),
                        ),
                    ],
                  ),
                  VSpacer.md(),
                  _Label(l10n.reportsLocationLabel),
                  CustomButton(
                    onTap: _editLocation,
                    borderRadius: BorderRadius.circular(14),
                    child: AppCard(
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 18,
                            color: GeneralColors.mutedColor,
                          ),
                          HSpacer(size: 10),
                          Expanded(
                            child: Text(
                              _location.isEmpty
                                  ? l10n.reportsLocationHint
                                  : _location,
                              style: GeneralTextStyle.bodyText(
                                fontSize: 15,
                                textColor: _location.isEmpty
                                    ? GeneralColors.mutedColor
                                    : GeneralColors.textColor,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: GeneralColors.mutedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  VSpacer.md(),
                  _Label(l10n.reportsDescriptionLabel),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _description,
                          minLines: 3,
                          maxLines: 6,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(_maxDescription),
                          ],
                          onChanged: (_) => setState(() {}),
                          style: GeneralTextStyle.bodyText(fontSize: 15),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        VSpacer.sm(),
                        Text(
                          '${_description.text.length} / $_maxDescription',
                          style: GeneralTextStyle.captionText(),
                        ),
                      ],
                    ),
                  ),
                  VSpacer.md(),
                  _PhotoBox(
                    photo: _photo,
                    isPreparing: _preparingPhoto,
                    onAdd: _addPhoto,
                    onRemove: () => setState(() => _photo = null),
                  ),
                  VSpacer.sm(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          LucideIcons.lock,
                          size: 14,
                          color: GeneralColors.mutedColor,
                        ),
                      ),
                      HSpacer(size: 6),
                      Expanded(
                        child: Text(
                          l10n.reportsPhotoNote,
                          style: GeneralTextStyle.captionText(height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          VSpacer(size: 12),
          PrimaryButton(
            height: 52,
            isEnable: _canSend,
            disabledColor: GeneralColors.borderColor,
            onPressed: _send,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.shield,
                  size: 18,
                  color: _canSend
                      ? GeneralColors.onPrimaryColor
                      : GeneralColors.mutedColor,
                ),
                HSpacer.sm(),
                Flexible(
                  child: Text(
                    l10n.reportsSend,
                    style: GeneralTextStyle.sectionText(
                      textColor: _canSend
                          ? GeneralColors.onPrimaryColor
                          : GeneralColors.mutedColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GeneralTextStyle.bodyText(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnonymityBanner extends StatelessWidget {
  const _AnonymityBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GeneralColors.anonymousSoftColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: GeneralColors.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.eyeOff,
              size: 18,
              color: GeneralColors.anonymousColor,
            ),
          ),
          HSpacer(size: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportsAnonymousTitle,
                  style: GeneralTextStyle.sectionText(
                    fontSize: 15,
                    textColor: GeneralColors.anonymousColor,
                  ),
                ),
                VSpacer.xs(),
                Text(
                  l10n.reportsAnonymousBody,
                  style: GeneralTextStyle.bodyText(
                    fontSize: 13,
                    textColor: GeneralColors.anonymousColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.photo,
    required this.isPreparing,
    required this.onAdd,
    required this.onRemove,
  });

  final Uint8List? photo;
  final bool isPreparing;
  final VoidCallback onAdd, onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = this.photo;
    if (photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              photo,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: l10n.reportsPhotoRemove,
              child: CustomButton(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: GeneralColors.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: GeneralColors.textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return CustomButton(
      onTap: isPreparing ? () {} : onAdd,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: SizedBox(
          height: 88,
          width: double.infinity,
          child: isPreparing
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.camera,
                      size: 22,
                      color: GeneralColors.mutedColor,
                    ),
                    VSpacer.sm(),
                    Text(
                      l10n.reportsPhotoAdd,
                      style: GeneralTextStyle.bodyText(
                        textColor: GeneralColors.mutedColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const _dash = 6.0, _gap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GeneralColors.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
