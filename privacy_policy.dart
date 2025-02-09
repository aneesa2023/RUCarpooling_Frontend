import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'This is the privacy policy content. You can replace this with your actual content.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
