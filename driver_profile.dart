import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';

class DriverProfile extends StatefulWidget {
  final String driverId;

  const DriverProfile({super.key, required this.driverId});

  @override
  DriverProfileState createState() => DriverProfileState();
}

class DriverProfileState extends State<DriverProfile> {
  Map<String, dynamic>? driverData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  /// Fetch Driver Data from API
  Future<void> _fetchDriverData() async {
    if (widget.driverId.isEmpty) {
      setState(() {
        errorMessage = "Invalid driver ID.";
        isLoading = false;
      });
      return;
    }

    try {
      // 🔹 Fetch driver profile
      final response = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/${widget.driverId}', // Fetch by driverId
      );

      // print("Driver Profile API Response: $response");

      if (mounted) {
        setState(() {
          driverData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load profile: ${e.toString()}";
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in _fetchDriverData: ${e.toString()}")),
      );
      // print("Error in _fetchDriverData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDriverData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (driverData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: driverData!['photo']?.isNotEmpty == true
                ? NetworkImage(driverData!['photo']) as ImageProvider
                : null,
            child: driverData!['photo']?.isEmpty != false
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 10),
          _buildPersonalDetailsCard(),
          const SizedBox(height: 16),
          _buildCollegeDetailsCard(),
          const SizedBox(height: 16),
          _buildRidesDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return _buildDetailCard(
      title: "Personal Details",
      details: [
        _buildDetailRow(
            Icons.person, 'Full Name', driverData!['user_name'] ?? "N/A"),
        _buildDetailRow(
            Icons.email, 'Email Address', driverData!['email'] ?? "N/A"),
        _buildDetailRow(
            Icons.phone, 'Phone Number', driverData!['phone'] ?? "N/A"),
        _buildDetailRow(
            Icons.speaker_notes, 'Bio', driverData!['bio'] ?? "N/A"),
      ],
    );
  }

  Widget _buildCollegeDetailsCard() {
    return _buildDetailCard(
      title: "College Details",
      details: [
        _buildDetailRow(
            Icons.school, 'College Name', driverData!['college_name'] ?? "N/A"),
        _buildDetailRow(
            Icons.badge, 'College ID', driverData!['ruid'] ?? "N/A"),
        _buildDetailRow(
            Icons.apartment, 'Department', driverData!['department'] ?? "N/A"),
      ],
    );
  }

  Widget _buildRidesDetailsCard() {
    return _buildDetailCard(
      title: "Ride Details",
      details: [
        _buildDetailRow(Icons.directions_car_sharp, 'No.of Rides Hosted',
            driverData!['hosted_rides_number'] ?? "0"),
        _buildDetailRow(Icons.star, 'Rating', driverData!['rating'] ?? "5/5"),
        _buildDetailRow(Icons.directions_car_sharp, 'No.of Rides Taken',
            driverData!['rides_number'] ?? "0"),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text("$label: $value", style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

Widget _buildDetailCard(
    {required String title, required List<Widget> details}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        ...details
      ]),
    ),
  );
}
