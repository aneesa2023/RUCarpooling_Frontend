import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/services/auth_service.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  RegisterDriverScreenState createState() => RegisterDriverScreenState();
}

class RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _issuingAuthorityController =
      TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  bool _isDeclarationChecked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _issuingAuthorityController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (_licenseNumberController.text.isEmpty ||
        _issuingAuthorityController.text.isEmpty ||
        _expirationDateController.text.isEmpty ||
        !_isDeclarationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all the fields and accept the declaration.",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final endpoint = "user/$userId";
      final Map<String, dynamic> updateData = {
        "is_driver": true,
        // "full_name": _fullNameController.text.trim(),
        // "license_number": _licenseNumberController.text.trim(),
        // "issuing_authority": _issuingAuthorityController.text.trim(),
        // "expiration_date": _expirationDateController.text.trim(),
      };

      await ApiService.putRequest(
        module: "user",
        endpoint: endpoint,
        body: updateData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are now registered as a driver!"),
        ),
      );

      Navigator.pop(context); // Close the screen after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to register: ${e.toString()}"),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as a Driver'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: "License Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issuingAuthorityController,
              decoration: const InputDecoration(
                labelText: "Issuing Authority",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expirationDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Expiration Date",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(
                        const Duration(days: 3650),
                      ),
                      onConfirm: (date) {
                        setState(() {
                          _expirationDateController.text =
                              DateFormat('MM-dd-yyyy').format(date);
                        });
                      },
                      currentTime: DateTime.now(),
                    );
                  },
                ),
              ),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime.now().add(
                    const Duration(days: 3650),
                  ),
                  onConfirm: (date) {
                    setState(() {
                      _expirationDateController.text =
                          DateFormat('MM-dd-yyyy').format(date);
                    });
                  },
                  currentTime: DateTime.now(),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDeclarationChecked,
                  onChanged: (value) {
                    setState(() {
                      _isDeclarationChecked = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    "I confirm that the above information is accurate and I am legally authorized to drive.",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
