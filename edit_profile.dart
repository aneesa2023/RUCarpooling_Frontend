import 'dart:io';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for user profile
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();

  // Controllers for vehicle input fields
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  List<Map<String, String>> _vehicles = [];
  int? _editingIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// Fetch User Profile & Vehicles
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final userResponse = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/$userId',
      );

      final vehicleResponse = await ApiService.getRequest(
        module: 'cars',
        endpoint: 'users/$userId/cars',
      );

      List<Map<String, String>> vehiclesList = [];

      if (vehicleResponse is Map<String, dynamic> &&
          vehicleResponse.containsKey('cars') &&
          vehicleResponse['cars'] is List) {
        vehiclesList = List<Map<String, String>>.from(
          vehicleResponse['cars'].map((car) => {
                'model': car['car_model']?.toString() ?? '',
                'license': car['license_number']?.toString() ?? '',
                'car_id': car['car_id']?.toString() ?? '',
              }),
        );
      }

      setState(() {
        _nameController.text = userResponse['name']?.toString() ?? '';
        _emailController.text = userResponse['email']?.toString() ?? '';
        _phoneController.text = userResponse['phone']?.toString() ?? '';
        _collegeNameController.text =
            userResponse['college_name']?.toString() ?? '';
        _collegeIdController.text = userResponse['ruid']?.toString() ?? '';
        _vehicles = vehiclesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
        );
      });
    }
  }

  /// Update Profile
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final body = {
        "email": _emailController.text,
        "phone": _phoneController.text,
        "college_name": _collegeNameController.text,
        "ruid": _collegeIdController.text,
      };

      await ApiService.putRequest(
        module: 'user',
        endpoint: 'user/$userId',
        body: body,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Pick Profile Image
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

/*  /// License Plate Scanner
  Future<void> _scanLicensePlate() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _licensePlateController.text =
            _extractLicenseNumber(recognizedText.text);
      });

      textRecognizer.close();
    }
  }

  /// Extract License Number from OCR Output
  String _extractLicenseNumber(String text) {
    RegExp regExp =
        RegExp(r'[A-Z0-9]{6,10}'); // Basic pattern for license numbers
    Iterable<Match> matches = regExp.allMatches(text);
    return matches.isNotEmpty ? matches.first.group(0) ?? '' : '';
  }*/

  Future<void> _addOrUpdateVehicle() async {
    String? userId = await AuthService.getUserId();
    if (userId == null) return;

    final Map<String, dynamic> carData = {
      "car_model": _vehicleModelController.text.trim(),
      "license_number": _licensePlateController.text.trim(),
    };

    try {
      if (_editingIndex != null) {
        // Update existing vehicle
        String carId = _vehicles[_editingIndex!]['car_id']!;
        await ApiService.putRequest(
          module: 'cars',
          endpoint: 'users/$userId/cars/$carId',
          body: carData,
        );

        // Update local list before fetching API data
        setState(() {
          _vehicles[_editingIndex!] = {
            "model": carData["car_model"],
            "license": carData["license_number"],
            "car_id": carId
          };
        });
      } else {
        // Add new vehicle
        final newVehicle = await ApiService.postRequest(
          module: 'cars',
          endpoint: 'users/$userId/cars',
          body: carData,
        );

        // Update the UI immediately by adding the new vehicle
        setState(() {
          _vehicles.add({
            "model": carData["car_model"],
            "license": carData["license_number"],
            "car_id": newVehicle["car_id"] ?? "",
          });
        });
      }

      // Reset form fields & editing index
      _vehicleModelController.clear();
      _licensePlateController.clear();
      _editingIndex = null;

      // Refresh user profile after update
      await _fetchUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save vehicle: ${e.toString()}")),
      );
    }
  }

  /// Delete Vehicle
  Future<void> _deleteVehicle(int index) async {
    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final carId = _vehicles[index]['car_id']; // Get the car ID

      if (carId == null || carId.isEmpty) {
        throw Exception("Invalid car ID");
      }

      await ApiService.deleteRequest(
        module: 'cars',
        endpoint: 'users/$userId/cars/$carId',
      );

      setState(() {
        _vehicles.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle Deleted Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete vehicle: ${e.toString()}")),
      );
    }
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileImagePicker(),
                  Text(
                    'Personal details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildEditableField('Full Name', _nameController),
                  _buildEditableField('Email', _emailController),
                  Text(
                    'College details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildEditableField('College Name', _collegeNameController),
                  _buildEditableField('College ID', _collegeIdController),
                  Text(
                    'Vehicle details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildEditableField('Vehicle Model', _vehicleModelController),
                  _buildEditableField('License Plate', _licensePlateController),
                  ElevatedButton(
                    onPressed: _addOrUpdateVehicle,
                    child: Text(_editingIndex != null
                        ? 'Update Vehicle'
                        : 'Add Vehicle'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _buildVehicleList(),
                ],
              ),
            ),
    );
  }

  Widget _buildVehicleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vehicles List",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _vehicles.isEmpty
            ? const Text("No vehicles added",
                style: TextStyle(color: Colors.grey))
            : Column(
                children: _vehicles.map((vehicle) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car,
                          color: Colors.blueAccent),
                      title: Text(vehicle['model'] ?? 'Unknown Model'),
                      subtitle:
                          Text('License Plate: ${vehicle['license'] ?? 'N/A'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                _vehicleModelController.text =
                                    vehicle['model'] ?? '';
                                _licensePlateController.text =
                                    vehicle['license'] ?? '';
                                _editingIndex = _vehicles.indexOf(vehicle);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteVehicle(_vehicles.indexOf(vehicle)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Profile Image Picker
  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                ? NetworkImage(_profileImageUrl!) as ImageProvider
                : null,
        child: (_profileImage == null &&
                (_profileImageUrl == null || _profileImageUrl!.isEmpty))
            ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
            : null,
      ),
    );
  }
}

Widget _buildEditableField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}
