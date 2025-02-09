import 'package:ru_carpooling/screens/rides/driver_profile.dart';
import 'package:ru_carpooling/screens/utilities/utils.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';

class ViewRideRequestsList extends StatefulWidget {
  final String rideId;

  const ViewRideRequestsList({super.key, required this.rideId});

  @override
  State<ViewRideRequestsList> createState() => _ViewRideRequestsListState();
}

class _ViewRideRequestsListState extends State<ViewRideRequestsList> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchRideRequests();
  }

  /// Fetch all ride requests from API
  Future<void> _fetchRideRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRequest(
        module: 'request_ride',
        endpoint: 'rides/${widget.rideId}/requests',
      );

      if (response.containsKey('requests')) {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(response["requests"]);
        });
        for (var request in _requests) {
          if (request.containsKey('rider_id')) {
            _fetchUserName(request['rider_id']);
          }
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No requests found for this ride.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching ride requests: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  /// Fetch driver name for a given driver ID
  Future<void> _fetchUserName(String userId) async {
    _isLoading = true;
    try {
      final response =
          await ApiService.getRequest(module: 'user', endpoint: 'user/$userId');

      if (response.containsKey('user_name')) {
        setState(() {
          userName = response['user_name'] ?? "--";
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching driver name: $e")),
      );
      // print("Error fetching driver name: $e");
    }
  }

  /// Accept or Reject Ride Request
  Future<void> _updateRequestStatus(
      String requestId, String action, int index, String riderId) async {
    bool confirmAction = await _showConfirmationDialog(action);
    if (!confirmAction) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        "user_id": riderId,
        "action": action,
      };

      final response = await ApiService.putRequest(
        module: 'request_ride',
        endpoint: 'rides/${widget.rideId}/request/$requestId',
        body: body,
      );
      // print(response.toString());
      if (response.containsKey('success') && response['success'] == true) {
        setState(() {
          _requests[index]['ride_status'] =
              action == 'accept' ? 'accept' : 'reject';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ride request ${action}ed successfully."),
            backgroundColor: Colors.green,
          ),
        );
        _fetchRideRequests();
      } else {
        throw Exception("Failed to $action request.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Confirmation Dialog
  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
                "${action[0].toUpperCase()}${action.substring(1)} Request!"),
            content: Text("Are you sure you want to $action this request?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Requests List"),
        backgroundColor: AppColors.primary,
      ),
      body: _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(
        child: Text("No ride requests found."),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRideRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Rider Name", userName.toString(),
                      textColor: Colors.black),
                  _buildDetailRow(
                      "Ride Status",
                      request['ride_status'][0].toUpperCase() +
                          request['ride_status'].substring(1),
                      textColor: (request['ride_status'] == 'accept' ||
                              request['ride_status'] == 'accepted')
                          ? Colors.green
                          : (request['ride_status'] == 'reject' ||
                                  request['ride_status'] == 'rejected')
                              ? Colors.red
                              : Colors.black),
                  _buildDetailRow(
                      "Requested At",
                      Utils.formatDate(
                        request['created_at'],
                      ),
                      textColor: Colors.black),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                        iconAlignment: IconAlignment.end,
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverProfile(
                                driverId: request['rider_id'],
                              ),
                            ),
                          );
                        },
                        label: Text(
                          "View Profile",
                          style: TextStyle(color: Colors.blue),
                        )),
                  ),
                  if (request['ride_status'] == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateRequestStatus(
                                request['request_id'],
                                "reject",
                                index,
                                request['rider_id']),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                            ),
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateRequestStatus(
                                request['request_id'],
                                "accept",
                                index,
                                request['rider_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Accept",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {required Color textColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
          ),
        ),
      ],
    );
  }
}
