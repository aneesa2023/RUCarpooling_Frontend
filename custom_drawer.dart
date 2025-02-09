import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  String? userId;
  String? userName;
  String? userEmail;
  bool isDriver = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// Fetch User Profile Data
  Future<void> _fetchUserProfile() async {
    try {
      String? fetchedUserId = await AuthService.getUserId();
      if (fetchedUserId == null) throw Exception("User ID not found");

      final userProfile = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/$fetchedUserId',
      );

      setState(() {
        userId = userProfile['user_id'] ?? "N/A";
        userName = userProfile['user_name'] ?? "";
        userEmail = userProfile['email'] ?? "N/A";
        isDriver = userProfile['is_driver'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userId = ", ";
        userName = "";
        userEmail = "";
        isDriver = false;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching user profile: $e"),
        ),
      );
      // print("Error fetching user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            accountName: isLoading
                ? const CircularProgressIndicator()
                : Text(
                    "Hello $userName",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
            accountEmail: isLoading
                ? null
                : Text(
                    userEmail ?? " ",
                    style: const TextStyle(color: Colors.black54),
                  ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home, 'Home', () {
                  Navigator.pushNamed(context, '/home');
                }),
                _buildDrawerItem(Icons.person, 'Profile', () {
                  Navigator.pushNamed(context, '/view_profile');
                }),
                // _buildDrawerItem(Icons.directions_car, 'My Trips', () {
                //   Navigator.pushNamed(context, '/my_trips');
                // }),
                //
                // // Show "Posted Rides List" Only If User is a Driver
                // if (isDriver)
                //   _buildDrawerItem(Icons.list_alt_rounded, 'Posted Rides List',
                //       () {
                //     Navigator.pushNamed(context, '/postedRides');
                //   }),

                _buildDrawerItem(Icons.notifications, 'Notifications', () {
                  Navigator.pushNamed(context, '/notifications');
                }),
                _buildDrawerItem(Icons.settings, 'Settings', () {
                  Navigator.pushNamed(context, '/settings');
                }),
                _buildDrawerItem(Icons.info, 'About', () {
                  Navigator.pushNamed(context, '/about');
                }),
                _buildDrawerItem(
                  Icons.logout,
                  'Logout',
                  () async {
                    await AuthService.clearToken();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
