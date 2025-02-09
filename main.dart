import 'package:ru_carpooling/screens/menu/about.dart';
import 'package:ru_carpooling/screens/auth/confirm_account.dart';
import 'package:ru_carpooling/screens/auth/login_screen.dart';
import 'package:ru_carpooling/screens/auth/signup_screen.dart';
import 'package:ru_carpooling/screens/menu/delete_account.dart';
import 'package:ru_carpooling/screens/menu/edit_profile.dart';
import 'package:ru_carpooling/screens/menu/help_support.dart';
import 'package:ru_carpooling/screens/home_page.dart';
import 'package:ru_carpooling/screens/menu/notifications.dart';
import 'package:ru_carpooling/screens/auth/onboarding_screen.dart';
import 'package:ru_carpooling/screens/rides/driver_registration.dart';
import 'package:ru_carpooling/screens/rides/my_trips.dart';
import 'package:ru_carpooling/screens/rides/post_ride_details.dart';
import 'package:ru_carpooling/screens/rides/post_ride_search.dart';
import 'package:ru_carpooling/screens/menu/privacy_policy.dart';
import 'package:ru_carpooling/screens/menu/view_profile.dart';
import 'package:ru_carpooling/screens/menu/settings.dart';
import 'package:ru_carpooling/screens/rides/posted_rides_list.dart';
import 'package:ru_carpooling/screens/rides/ride_search.dart';
import 'package:ru_carpooling/services/auth_service.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RU Carpooling',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          primaryColor:  AppColors.primary,),
      home: const AuthChecker(),
      // initialRoute: '/',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/confirm_account': (context) => ConfirmAccountScreen(),
        '/home': (context) => HomePage(),
        '/view_profile': (context) => ViewProfileScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/settings': (context) => Settings(),
        '/privacy_policy': (context) => PrivacyPolicyScreen(),
        '/delete_account': (context) => DeleteAccountScreen(),
        '/help_support': (context) => HelpAndSupportScreen(),
        '/about': (context) => AboutScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/my_trips': (context) => MyTripsScreen(),
        '/searchRide': (context) => RideSearchScreen(),
        '/postRide': (context) => PostRideLocationScreen(),
        '/postRideDetails': (context) => PostRideDetails(
              fromLocation: '',
              fromLat: 0,
              fromLong: 0,
              toLocation: '',
              toLat: 0,
              toLong: 0,
              departureTime: '',
            ),
        '/registerDriver': (context) => RegisterDriverScreen(),
        '/postedRides': (context) => PostedRidesList(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If logged in, go to HomePage; otherwise, go to OnboardingScreen
        return snapshot.data == true
            ? const HomePage()
            : const OnboardingScreen();
      },
    );
  }
}
