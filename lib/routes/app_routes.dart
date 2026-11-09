import 'package:flutter/widgets.dart';
import 'package:hostel/shared/main_scaffold.dart';

class AppRoutes {
  AppRoutes._();

  static final Map<String, WidgetBuilder> routes = {
    MainScaffold.path: (_) => const MainScaffold(),
  };
}
