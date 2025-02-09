import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('About'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // App Logo
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 10),
                  // App Name
                  Text(
                    'RU Carpooling',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  // App Tagline
                  Text(
                    'Your Trusted Carpooling Solution',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),

            // About the App
            Text(
              'About the App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'RU Carpooling is a carpooling platform designed specifically for university students. '
              'Our goal is to reduce travel costs, promote sustainable transportation, and provide a stress-free commuting experience.',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),

            // Features
            Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '• Host and search for rides.\n'
              '• Real-time ride tracking and notifications.\n'
              '• User profiles with vehicle and ID verification.\n'
              '• In-app chat for ride arrangements.\n'
              '• Secure and seamless experience.',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),

            // Contact Info
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: support@campusconnect.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Phone: +1 123-456-7890',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
