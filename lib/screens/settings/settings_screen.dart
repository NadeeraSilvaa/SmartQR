import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartqr_plus/providers/theme_provider.dart';
import 'package:smartqr_plus/utils/app_colors.dart';
import 'package:smartqr_plus/widgets/admob_banner_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings
            _SettingsSection(
              title: 'Appearance',
              children: [
                _SettingTile(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: themeProvider.themeMode == ThemeMode.light
                      ? 'Light'
                      : themeProvider.themeMode == ThemeMode.dark
                          ? 'Dark'
                          : 'System',
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            _SettingsSection(
              title: 'About',
              children: [
                _SettingTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0 (Build 1)',
                  onTap: () {
                    _showVersionInfo(context);
                  },
                ),
                _SettingTile(
                  icon: Icons.description,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  onTap: () {
                    _showPrivacyPolicy(context);
                  },
                ),
                _SettingTile(
                  icon: Icons.code,
                  title: 'Credits',
                  subtitle: 'About SmartQR+',
                  onTap: () {
                    _showCredits(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // AdMob Banner Placeholder
            const AdMobBannerWidget(),
          ],
        ),
      ),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SmartQR+'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            SizedBox(height: 16),
            Text('A modern QR Code Generator and Scanner app with AI-enhanced features.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'Last Updated: [Date]\n\n'
            'SmartQR+ respects your privacy. This app:\n\n'
            '• Stores QR code history locally on your device\n'
            '• Does not collect personal information\n'
            '• Does not share data with third parties\n'
            '• May use anonymous analytics for app improvement\n\n'
            'For AI features, data is sent to OpenAI API for processing. '
            'No personal information is stored by OpenAI.\n\n'
            'If you have questions, contact us at [email].',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCredits(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credits'),
        content: const SingleChildScrollView(
          child: Text(
            'SmartQR+\n\n'
            'Developed with Flutter\n\n'
            'Packages Used:\n'
            '• qr_flutter - QR code generation\n'
            '• mobile_scanner - QR code scanning\n'
            '• hive_flutter - Local storage\n'
            '• provider - State management\n'
            '• lottie - Animations\n'
            '• google_fonts - Typography\n\n'
            '© 2024 SmartQR+. All rights reserved.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

