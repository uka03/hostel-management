import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/routes/app_routes.dart';
import 'package:hostel/shared/main_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/shared/provider/session_store.dart';
import 'package:hostel/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // The client needs the session and the session needs the client, so each
  // reaches the other through a closure.
  late final AuthProvider auth;
  final client = DioClient(tokenGetter: () => auth.validAccessToken());
  auth = AuthProvider(
    api: () => AuthApi(client.dio),
    store: SecureSessionStore(),
  )..restore();

  runApp(MyApp(auth: auth, client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.auth, required this.client});

  final AuthProvider auth;
  final DioClient client;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider.value(value: client),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        locale: const Locale('mn'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        initialRoute: MainScaffold.path,
        routes: AppRoutes.routes,
        builder: EasyLoading.init(),
      ),
    );
  }
}
