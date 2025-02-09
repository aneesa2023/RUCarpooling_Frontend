import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingOption('Privacy Policy / Terms', () {
              Navigator.pushNamed(context, '/privacy_policy');
            }),
            _buildSettingOption('Delete or Deactivate Account', () {
              Navigator.pushNamed(context, '/delete_account');
            }),
            _buildSettingOption('Help and Support', () {
              Navigator.pushNamed(context, '/help_support');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
