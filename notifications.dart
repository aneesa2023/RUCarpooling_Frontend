import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});
  final List<Map<String, String>> notifications = [
    {
      'title': 'Ride Confirmed',
      'subtitle': 'Your ride to the airport has been confirmed.',
      'time': '10 mins ago',
    },
    {
      'title': 'New Ride Match',
      'subtitle': 'A new ride matches your search for downtown.',
      'time': '1 hour ago',
    },
    {
      'title': 'Profile Update',
      'subtitle': 'Your profile information has been successfully updated.',
      'time': '2 hours ago',
    },
    {
      'title': 'Payment Reminder',
      'subtitle': 'Please pay for your recent trip to complete the booking.',
      'time': 'Yesterday',
    },
    {
      'title': 'Ride Cancelled',
      'subtitle': 'Your scheduled ride has been cancelled by the host.',
      'time': '2 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notifications,
                            color: AppColors.primary, size: 30),
                        SizedBox(width: 10),
                        // Notification Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                notification['subtitle']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Time
                        Text(
                          notification['time']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
