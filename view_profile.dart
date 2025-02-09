import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  ViewProfileScreenState createState() => ViewProfileScreenState();
}

class ViewProfileScreenState extends State<ViewProfileScreen> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) {
        if (mounted) {
          setState(() {
            errorMessage = "User ID not found";
            isLoading = false;
          });
        }
        return;
      }

      // Fetch user profile
      final userResponse = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/$userId',
      );

      // Fetch vehicle details
      final vehicleResponse = await ApiService.getRequest(
        module: 'cars',
        endpoint: 'users/$userId/cars',
      );

      // print("Vehicle API Response: $vehicleResponse");

      List<Map<String, dynamic>> vehiclesList = [];

      if (vehicleResponse.containsKey('cars') &&
          vehicleResponse['cars'] is List) {
        List<dynamic> vehicleData = vehicleResponse['cars'];

        for (var item in vehicleData) {
          if (item is Map<String, dynamic>) {
            vehiclesList.add({
              'car_model': item['car_model'] ?? "N/A",
              'license_number': item['license_number'] ?? "N/A",
              'car_id': item['car_id'] ?? "N/A",
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong.")),
        );
      }

      if (mounted) {
        setState(() {
          userData = userResponse;
          vehicles = vehiclesList;
          isLoading = false;
        });
      }
      // for (var vehicle in vehicles) {
      //   print(
      //       "   - Model: ${vehicle['car_model']} | License: ${vehicle['license_number']}");
      // }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load profile: ${e.toString()}";
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in _fetchUserData: $e")),
      );
      // print("Error in _fetchUserData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await Navigator.pushNamed(context, '/edit_profile');
              _fetchUserData(); // Refresh profile data after editing
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
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
    if (userData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userData!['photo']?.isNotEmpty == true
                ? NetworkImage(userData!['photo']) as ImageProvider
                : null,
            child: userData!['photo']?.isEmpty != false
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 10),
          _buildPersonalDetailsCard(),
          const SizedBox(height: 16),
          _buildCollegeDetailsCard(),
          const SizedBox(height: 16),
          _buildVehicleDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return _buildDetailCard(
      title: "Personal Details",
      details: [
        _buildDetailRow(
            Icons.person, 'Full Name', userData!['user_name'] ?? "N/A"),
        _buildDetailRow(
            Icons.email, 'Email Address', userData!['email'] ?? "N/A"),
        _buildDetailRow(
            Icons.phone, 'Phone Number', userData!['phone'] ?? "N/A"),
      ],
    );
  }

  Widget _buildCollegeDetailsCard() {
    return _buildDetailCard(
      title: "College Details",
      details: [
        _buildDetailRow(
            Icons.school, 'College Name', userData!['college_name'] ?? "N/A"),
        _buildDetailRow(Icons.badge, 'College ID', userData!['ruid'] ?? "N/A"),
      ],
    );
  }

  Widget _buildVehicleDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        vehicles.isEmpty
            ? _buildEmptyVehicleCard()
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _buildVehicleDetailsCard(
                    vehicleName: vehicle['car_model']!,
                    licensePlate: vehicle['license_number']!,
                    carId: vehicle['car_id']!,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyVehicleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            Icon(Icons.directions_car_outlined, color: Colors.grey),
            SizedBox(width: 8),
            Text("No vehicles registered"),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsCard({
    required String vehicleName,
    required String licensePlate,
    required String carId,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.directions_car, 'Model', vehicleName),
            _buildDetailRow(
                Icons.confirmation_number, 'License Plate', licensePlate),
          ],
        ),
      ),
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
