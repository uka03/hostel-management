import 'package:flutter/widgets.dart';

/// Calls [onVisible] each time this becomes the visible tab, so screens show
/// changes made elsewhere and hidden tabs don't load until they're opened.
class ReloadWhenVisible extends StatefulWidget {
  const ReloadWhenVisible({
    super.key,
    required this.onVisible,
    required this.child,
  });

  final void Function(BuildContext context) onVisible;
  final Widget child;

  @override
  State<ReloadWhenVisible> createState() => _ReloadWhenVisibleState();
}

class _ReloadWhenVisibleState extends State<ReloadWhenVisible> {
  bool _wasVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = Visibility.of(context);
    if (visible && !_wasVisible) widget.onVisible(context);
    _wasVisible = visible;
  }

  @override
  Widget build(BuildContext context) {
    // Hidden tabs stay built, so stop their animations, like loading spinners.
    return TickerMode(enabled: Visibility.of(context), child: widget.child);
  }
}
