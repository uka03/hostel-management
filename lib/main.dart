import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/routes/app_routes.dart';
import 'package:hostel/shared/main_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<DioClient>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            return DioClient(
              tokenGetter: () => auth.token,
              onUnauthorized: auth.clear,
            );
          },
          dispose: (_, client) => client.close(),
        ),
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
