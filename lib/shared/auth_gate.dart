import 'package:flutter/material.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/pages/auth/name_page.dart';
import 'package:hostel/pages/auth/pending_page.dart';
import 'package:hostel/pages/auth/phone_page.dart';
import 'package:hostel/shared/main_scaffold.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:provider/provider.dart';

/// Picks the login flow, the approval wait or the tab shell.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    final residentStatus = context.select<AuthProvider, ResidentStatus?>(
      (a) => a.user?.status,
    );
    final needsName = context.select<AuthProvider, bool>(
      (a) => a.user != null && (a.user!.name ?? '').trim().isEmpty,
    );
    return switch (status) {
      AuthStatus.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.signedOut => const PhonePage(),
      AuthStatus.signedIn when needsName => const NamePage(),
      AuthStatus.signedIn =>
        residentStatus == ResidentStatus.pending ||
                residentStatus == ResidentStatus.left
            ? const PendingPage()
            : const MainScaffold(),
    };
  }
}
