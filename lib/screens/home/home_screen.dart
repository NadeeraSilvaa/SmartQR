import 'package:flutter/material.dart';
import 'package:smartqr_plus/screens/generator/generator_screen.dart';
import 'package:smartqr_plus/screens/history/history_screen.dart';
import 'package:smartqr_plus/screens/scanner/scanner_screen.dart';
import 'package:smartqr_plus/screens/settings/settings_screen.dart';
import 'package:smartqr_plus/utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GeneratorScreen(),
    const ScannerScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.2),
          elevation: 0,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_2),
              selectedIcon: Icon(Icons.qr_code_2, color: AppColors.primary),
              label: 'Generate',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner),
              selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history, color: AppColors.primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              selectedIcon: Icon(Icons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

