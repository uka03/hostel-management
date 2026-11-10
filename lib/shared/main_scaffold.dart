import 'package:flutter/material.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/pages/cleaning/cleaning_page.dart';
import 'package:hostel/pages/home/home_page.dart';
import 'package:hostel/pages/profile/profile_page.dart';
import 'package:hostel/pages/purchases/purchases_page.dart';
import 'package:hostel/pages/reports/reports_page.dart';
import 'package:hostel/shared/components/app_tab_bar.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/utils/colors.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static const String path = "/";

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeneralColors.backgroundColor,
      bottomNavigationBar: AppTabBar(
        selectedIndex: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
      ),
      body: Selector<AuthProvider, UserResponseData?>(
        selector: (_, auth) => auth.user,
        builder: (context, user, _) {
          return IndexedStack(
            index: _selectedIndex,
            children: [
              HomePage(
                onOpenTab: (index) => setState(() => _selectedIndex = index),
              ),
              const CleaningPage(),
              const PurchasesPage(),
              const ReportsPage(),
              const ProfilePage(),
            ],
          );
        },
      ),
    );
  }
}
