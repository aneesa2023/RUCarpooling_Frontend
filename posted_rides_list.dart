import 'package:ru_carpooling/screens/rides/posted_ride_details.dart';
import 'package:ru_carpooling/screens/rides/view_ride_requests_list.dart';
import 'package:ru_carpooling/screens/utilities/utils.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';

class PostedRidesList extends StatefulWidget {
  const PostedRidesList({super.key});

  @override
  State<PostedRidesList> createState() => _PostedRidesListState();
}

class _PostedRidesListState extends State<PostedRidesList> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPostedRides();
  }

  final List<Map<String, dynamic>> _scheduledRides = [];
  final List<Map<String, dynamic>> _cancelledRides = [];
  final List<Map<String, dynamic>> _completedRides = [];

  Future<void> _fetchPostedRides() async {
    setState(() => _isLoading = true);

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final response = await ApiService.getRequest(
        module: 'post_ride',
        endpoint: '$userId/rides',
      );

      // print("API Response: $response");

      if (response.containsKey('car_rides') && response['car_rides'] is List) {
        List<dynamic> rideData = response['car_rides'];

        _scheduledRides.clear();
        _cancelledRides.clear();
        _completedRides.clear();

        for (var item in rideData) {
          if (item is Map<String, dynamic>) {
            Map<String, dynamic> ride = {
              "ride_id": item["ride_id"] ?? "N/A",
              "car_id": item["car_id"] ?? "N/A",
              "from_location": item["from_location"]?.toString() ?? "N/A",
              "to_location": item["to_location"]?.toString() ?? "N/A",
              "departure_time": Utils.formatDate(item["departure_time"]),
              "created_at": Utils.formatDate(item["created_at"]),
              "ride_status": item["ride_status"]?.toString() ?? "N/A",
              "total_seats": _parseSeats(item["total_seats"]),
              "available_seats": _parseSeats(item["available_seats"]),
              "note": item["note"]?.toString() ?? "No notes",
              "ride_price": item["ride_price"].toString(),
              "from_lat": item["from_lat"],
              "from_long": item["from_long"],
              "to_lat": item["to_lat"],
              "to_long": item["to_long"],
              "pet_friendly": item["pet_friendly"],
              "trunk_space": item["trunk_space"],
              "wheelchair_access": item["wheelchair_access"],
            };

            // Sort rides into different lists
            if (ride["ride_status"] == "scheduled") {
              _scheduledRides.add(ride);
            } else if (ride["ride_status"] == "cancelled") {
              _cancelledRides.add(ride);
            } else if (ride["ride_status"] == "completed") {
              _completedRides.add(ride);
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("No car rides data found or incorrect format.")),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load rides: ${e.toString()}";
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching rides: ${e.toString()}")),
      );
      // print("Error fetching rides: $e");
    }
  }

  Future<void> _cancelRide(String rideId) async {
    bool confirmCancel = await _showCancelConfirmationDialog();
    if (!confirmCancel) return;

    setState(() {
      _isLoading = true;
    });

    final body = {
      "ride_status": "cancelled",
      "updated_at": DateTime.now().toIso8601String()
    };

    try {
      final response = await ApiService.putRequest(
        module: 'post_ride',
        endpoint: 'rides/$rideId',
        body: body,
      );

      if (response['success'] == true) {
        await _fetchPostedRides();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ride cancelled successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to cancel ride.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cancel Ride"),
            content: const Text("Are you sure you want to cancel this ride?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  num _parseSeats(dynamic seatValue) {
    if (seatValue is num) return seatValue;
    if (seatValue is String) return double.tryParse(seatValue) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Posted Rides"),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Cancelled"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildRideList("scheduled"),
                      _buildRideList("cancelled"),
                      _buildRideList("completed"),
                    ],
                  ),
      ),
    );
  }

// Helper function to filter rides based on status
  Widget _buildRideList(String status) {
    List<Map<String, dynamic>> rideList;

    if (status == "scheduled") {
      rideList = _scheduledRides;
    } else if (status == "cancelled") {
      rideList = _cancelledRides;
    } else if (status == "completed") {
      rideList = _completedRides;
    } else {
      rideList = _scheduledRides;
    }

    if (rideList.isEmpty) {
      return const Center(
        child: Text("No rides available."),
      );
    }
    String getEnabledOptions(Map<String, dynamic> ride) {
      List<String> enabledOptions = [];

      if (ride['pet_friendly']) enabledOptions.add("Pet Friendly");
      if (ride['trunk_space']) enabledOptions.add("Trunk Space");
      if (ride['wheelchair_access']) {
        enabledOptions.add("Wheelchair Accessible");
      }

      return enabledOptions.isNotEmpty
          ? enabledOptions.join(", ")
          : "No Additional Features Available";
    }

    return RefreshIndicator(
      onRefresh: _fetchPostedRides,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primary,
            ))
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : rideList.isEmpty
                  ? const Center(child: Text("No rides posted yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: rideList.length,
                      itemBuilder: (context, index) {
                        final ride = rideList[index];

                        return GestureDetector(
                          onTap: () {
                            // Navigate to Ride Details Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostedRideDetailsScreen(ride: ride),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            color: Colors.grey[200], // Background color
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ride['departure_time']!,
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '\$ ${ride['ride_price']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    ride['to_location']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (status == "scheduled")
                                        Expanded(
                                            child: TextButton(
                                          onPressed: () =>
                                              _cancelRide(ride['ride_id']),
                                          child: const Text(
                                            'Cancel Ride',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: AppColors.primary),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewRideRequestsList(
                                                  rideId: '${ride['ride_id']}',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'View All Requests',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
