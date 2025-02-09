import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  MyTripsScreenState createState() => MyTripsScreenState();
}

class MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor:  AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              text: 'Upcoming',
            ),
            Tab(
              text: 'Past trips',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripList('upcoming'),
          _buildTripList('past'),
        ],
      ),
    );
  }

  Widget _buildTripList(String tripType) {
    final List<Map<String, String>> trips = tripType == 'upcoming'
        ? [
            {
              'name': 'John Doe',
              'rating': '4.8',
              'location': 'Union Square, New York, NY',
              'destination': 'Times Square, New York, NY',
              'price': '\$15',
              'vehicle': 'Toyota Camry (White)',
              'time': 'Coming in 5 mins',
            },
            {
              'name': 'Emma Watson',
              'rating': '4.9',
              'location': 'San Francisco Airport, CA',
              'destination': 'Downtown San Francisco, CA',
              'price': '\$25',
              'vehicle': 'Tesla Model 3 (Blue)',
              'time': 'Coming in 10 mins',
            },
          ]
        : [
            {
              'name': 'Sophia Lee',
              'rating': '4.8',
              'location': 'Santa Monica Pier, CA',
              'destination': 'LAX Airport, Los Angeles, CA',
              'price': '\$30',
              'vehicle': 'Ford Escape (Gray)',
              'time': 'Completed on Dec 25, 2023',
            },
            {
              'name': 'David Miller',
              'rating': '4.7',
              'location': 'Grand Central Terminal, New York, NY',
              'destination': 'Yankee Stadium, Bronx, NY',
              'price': '\$20',
              'vehicle': 'Chevrolet Malibu (Red)',
              'time': 'Completed on Dec 24, 2023',
            },
          ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Host Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 25,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                trip['rating']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      trip['time']!,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Trip Details
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['location']!,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const Icon(Icons.arrow_downward,
                            color: Colors.grey, size: 16),
                        Text(
                          trip['destination']!,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip['price'].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Vehicle',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip['vehicle']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip['time']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cancel Button for Upcoming Trips
                if (tripType == 'upcoming')
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle cancel action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text(
                        'Cancel Request',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
