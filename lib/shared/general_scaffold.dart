import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';

class GeneralScaffold extends StatelessWidget {
  const GeneralScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.padding,
    this.horizontalPadding,
    this.bottomBar,
    this.verticalPadding,
    this.bottom = true,
    this.top = true,
    this.extendBodyBehindAppBar = false,
  });
  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Widget? bottomBar;
  final bool bottom, extendBodyBehindAppBar, top;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      backgroundColor: GeneralColors.backgroundColor,
      bottomNavigationBar: bottomBar,
      body: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 20.0,
              vertical: verticalPadding ?? 20.0,
            ),
        child: SafeArea(top: top, bottom: bottom, child: child),
      ),
    );
  }
}
