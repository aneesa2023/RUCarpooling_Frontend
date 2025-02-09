import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete or deactivate your account?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Deleting your account will permanently erase all your data. Deactivating your account will allow you to reactivate it later.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle account deletion logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account Deleted'),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Delete Account',
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                // Handle account deactivation logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Account Deactivated',
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Deactivate Account'),
            ),
          ],
        ),
      ),
    );
  }
}
