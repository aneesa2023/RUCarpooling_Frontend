import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> onboardData = [
    {
      'title': 'RU Carpooling',
      'subtitle':
          'Reduce Cost\nJoin the carpooling community and save time and money on your daily commute.'
    },
    {
      'title': 'RU Carpooling',
      'subtitle':
          'Save Environment\nReduce your carbon footprint and help to reduce traffic congestion.'
    },
    {
      'title': 'RU Carpooling',
      'subtitle':
          'Stress Free Commute\nEnjoy a stress-free commute with real-time carpool tracking and notifications.'
    },
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding screens
          PageView.builder(
            itemCount: onboardData.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      onboardData[index]['title']!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      onboardData[index]['subtitle']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
          // Dots indicator
          Positioned(
            bottom: 220,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardData.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentPage == index ? 16 : 8,
                  decoration: BoxDecoration(
                    color:
                        currentPage == index ? AppColors.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          // Bottom buttons
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Login'),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text('Sign up'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
