import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ru_carpooling/services/api_service.dart';

class ConfirmAccountScreen extends StatefulWidget {
  const ConfirmAccountScreen({super.key});

  @override
  ConfirmAccountScreenState createState() => ConfirmAccountScreenState();
}

class ConfirmAccountScreenState extends State<ConfirmAccountScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController confirmationCodeController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> confirmAccount() async {
    if (usernameController.text.isEmpty ||
        confirmationCodeController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Both fields are required."),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> body = {
      "username": usernameController.text,
      "confirmation_code": confirmationCodeController.text,
    };

    try {
      await ApiService.postRequest(
        module: 'auth',
        endpoint: 'confirm',
        body: body,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account confirmed! Please sign in."),
        ),
      );

      Navigator.pushNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Account'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Confirm Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmationCodeController,
              decoration: const InputDecoration(
                labelText: 'Confirmation Code',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : confirmAccount,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Confirm Account'),
            ),
          ],
        ),
      ),
    );
  }
}
