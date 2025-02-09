import 'package:ru_carpooling/screens/rides/view_available_ride_details.dart';
import 'package:ru_carpooling/screens/utilities/utils.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AvailableRidesList extends StatefulWidget {
  final String fromLocation;
  final double fromLat;
  final double fromLong;
  final String toLocation;
  final double toLat;
  final double toLong;
  final String departureTime;
  final bool petFriendly;
  final bool trunkSpace;
  final bool wheelchairAccess;
  final int seatsRequested;

  const AvailableRidesList({
    super.key,
    required this.fromLocation,
    required this.fromLat,
    required this.fromLong,
    required this.toLocation,
    required this.toLat,
    required this.toLong,
    required this.departureTime,
    required this.petFriendly,
    required this.trunkSpace,
    required this.wheelchairAccess,
    required this.seatsRequested,
  });

  @override
  State<AvailableRidesList> createState() => _AvailableRidesListState();
}

class _AvailableRidesListState extends State<AvailableRidesList> {
  List<Map<String, dynamic>> _rides = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? riderUserId;
  TextEditingController noteController = TextEditingController();
  final Map<String, String> _driverNames = {};

  @override
  void initState() {
    super.initState();
    _fetchSearchedRides();
    _loadUserDetails();
  }

  /// Fetch available rides from API
  Future<void> _fetchSearchedRides() async {
    setState(() {
      _isLoading = true; // Ensure loading is set before making the API call
      _errorMessage = null;
    });

    try {
      final routeDetails = {
        "from_lat": widget.fromLat,
        "from_long": widget.fromLong,
        "to_lat": widget.toLat,
        "to_long": widget.toLong,
        "departure_time": widget.departureTime,
        "pet_friendly": widget.petFriendly,
        "trunk_space": widget.trunkSpace,
        "wheelchair_access": widget.wheelchairAccess,
        "seats_requested": widget.seatsRequested
      };

      final response = await ApiService.postRequest(
        module: 'search_ride',
        endpoint: 'rides/search',
        body: routeDetails,
      );

      if (response.containsKey('rides')) {
        List<Map<String, dynamic>> rideList =
            List<Map<String, dynamic>>.from(response["rides"]);

        // Fetch driver names for each ride
        for (var ride in rideList) {
          String driverId = ride['user_id'];
          String rideId = ride['ride_id'];
          if (!_driverNames.containsKey(driverId)) {
            _fetchDriverName(driverId);
          }
          // Fetch ride request status for each ride
          _fetchRideRequests(rideId).then((status) {
            setState(() {
              ride['ride_status'] = status; // Update ride status dynamically
            });
          });
        }

        setState(() {
          _rides = rideList;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load rides. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching rides: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false; // Ensure _isLoading is set to false after API call
      });
    }
  }

  /// Fetch driver name for a given driver ID
  Future<void> _fetchDriverName(String driverId) async {
    try {
      final response = await ApiService.getRequest(
          module: 'user', endpoint: 'user/$driverId');

      if (response.containsKey('user_name')) {
        setState(() {
          _driverNames[driverId] = response['user_name'] ?? "--";
          _isLoading = false;
        });
      }
    } catch (e) {
      _errorMessage = "Error fetching driver name: ${e.toString()}";
    }
  }

  Future<String> _fetchRideRequests(String rideId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getRequest(
        module: 'request_ride',
        endpoint: 'rides/$rideId/requests',
      );

      if (response.containsKey('requests')) {
        List<Map<String, dynamic>> requests =
            List<Map<String, dynamic>>.from(response["requests"]);

        for (var request in requests) {
          if (request.containsKey('ride_status')) {
            return request['ride_status']; // Return the first ride status found
          }
        }
      }
      return "available"; // Default if no request found
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching ride requests: ${e.toString()}";
      });
      return "available"; // Default status in case of an error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserDetails() async {
    String? storedUserId = await AuthService.getUserId();
    if (storedUserId != null) {
      riderUserId = storedUserId;
    } else {
      setState(() {
        riderUserId = 'Unknown';
      });
    }
  }

  Future<void> _showNoteDialog(String riderUserId, String rideId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a Note"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: "Enter your message for the driver",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestRide(riderUserId, rideId, noteController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              "Send Request",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRide(
      String riderUserId, String rideId, String notes) async {
    try {
      final requestPayload = {
        "rider_id": riderUserId,
        "ride_status": "pending",
        "seats_requested": widget.seatsRequested,
        "notes": notes
      };
      // print(requestPayload);
      _isLoading = true;
      print("$rideId-----$riderUserId");
      final response = await ApiService.postRequest(
        module: 'request_ride',
        endpoint: 'rides/$rideId/request',
        body: requestPayload,
      );

      if (response.containsKey("message")) {
        print("test print$response");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"]),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _fetchSearchedRides();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to request ride: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to request ride: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Available Rides"),
        backgroundColor: AppColors.primary,
      ),
      body: _buildRideList("scheduled"),
    );
  }

  Widget _buildRideList(String status) {
    List<Map<String, dynamic>> rideList;

    rideList = _rides;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator()); // Ensure loading is displayed
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (rideList.isEmpty) {
      return const Center(
        child: Text("No rides available."),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSearchedRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: rideList.length,
        itemBuilder: (context, index) {
          final ride = rideList[index];
          final String driverId = ride['user_id'];
          final String driverName = _driverNames[driverId] ?? "Loading...";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAvailableRideDetails(ride: ride),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              color: Colors.white, // Background color
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      "Ride with: $driverName",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ride['to_location']!,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Utils.formatDate("${ride['departure_time']!}"),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "\$ ${ride['ride_price']}",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ride['ride_status'] == "pending"
                            ? null
                            : _showNoteDialog(ride['user_id'], ride['ride_id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: Text(
                        ride['ride_status'] == "pending"
                            ? 'Requested Ride'
                            : 'Request Ride',
                        style: TextStyle(color: Colors.white),
                      ),
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
