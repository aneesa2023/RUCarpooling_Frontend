import 'package:ru_carpooling/screens/menu/custom_drawer.dart';
import 'package:ru_carpooling/services/auth_service.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? userId;
  bool? isDriverRegistered;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  /// Fetch User ID & Driver Status
  Future<void> _loadUserDetails() async {
    String? storedUserId = await AuthService.getUserId();
    if (storedUserId != null) {
      _fetchDriverStatus(storedUserId);
    } else {
      setState(() {
        userId = 'Unknown';
        isLoading = false;
      });
    }
  }

  /// Fetch `is_driver` from API
  Future<void> _fetchDriverStatus(String userId) async {
    try {
      final response = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/$userId',
      );

      bool isDriver = response['is_driver'] ?? false;

      setState(() {
        this.userId = userId;
        isDriverRegistered = isDriver;
        isLoading = false;
      });

      // print("User ID: $userId | is_driver: $isDriver");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
      // print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RU Carpooling'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ListView(padding: EdgeInsets.all(20), children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/searchRide');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200, 50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Search for a Ride'),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/my_trips');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200, 50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('My Trips'),
                ),
                const SizedBox(height: 20),
                Text(
                  'NOTE: You need to have a verified driving licence and Register as Driver to host Rides',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (isDriverRegistered == true) {
                      Navigator.pushNamed(context, '/postRide');
                    } else {
                      final result =
                          await Navigator.pushNamed(context, '/registerDriver');

                      if (result != null) {
                        _loadUserDetails();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Post a Ride'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (isDriverRegistered == true) {
                      Navigator.pushNamed(context, '/postedRides');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Do not have any rides list yet",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Posted Rides List'),
                ),
                const SizedBox(height: 20),
              ]),
        //TODO
        /*Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    FeatureCard(
                      title: "Rides",
                      subtitle: "Post or search for rides",
                      icon: Icons.directions_car_rounded,
                      color: Colors.brown.shade600,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.all(60),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (isDriverRegistered == true) {
                                        Navigator.pushNamed(
                                            context, '/postRide');
                                      } else {
                                        final result =
                                            await Navigator.pushNamed(
                                                context, '/registerDriver');

                                        if (result != null) {
                                          _loadUserDetails();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.brown,
                                      minimumSize: const Size(200, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Post a Ride'),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/searchRide');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      minimumSize: const Size(200, 50),
                                      side:
                                          const BorderSide(color: Colors.brown),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Search for a Ride'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    FeatureCard(
                      title: "Find Roommates",
                      subtitle: "Search based on budget, gender, location",
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FindRoommatesScreen()),
                      ),
                    ),
                    FeatureCard(
                      title: "Subleasing",
                      subtitle: "Find available subleases and lease out",
                      icon: Icons.home_rounded,
                      color: Colors.teal.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubleasingScreen()),
                      ),
                    ),
                    FeatureCard(
                      title: "Move Out Sale",
                      subtitle: "Buy and sell used items",
                      icon: Icons.shopping_cart_rounded,
                      color: Colors.orange.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MoveOutSaleScreen()),
                      ),
                    ),
                    FeatureCard(
                      title: "Community Feed",
                      subtitle: "Post updates, ask questions, and share info",
                      icon: Icons.forum_rounded,
                      color: Colors.purple.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommunityFeedScreen()),
                      ),
                    ),
                    FeatureCard(
                      title: "Polls",
                      subtitle: "Vote and create opinion polls",
                      icon: Icons.poll_rounded,
                      color: Colors.red.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PollsScreen()),
                      ),
                    ),
                  ],
                ),
              ),*/
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        shadowColor: Colors.grey.shade400,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 30,
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade600, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
