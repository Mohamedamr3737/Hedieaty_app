import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  // Sample list of notifications
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "New Event Created",
      "message": "Your event 'Birthday Party' was successfully created.",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "icon": Icons.event,
    },
    {
      "title": "Gift Pledged",
      "message": "Someone pledged a gift for your 'Wedding Anniversary' event.",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "icon": Icons.card_giftcard,
    },
    {
      "title": "Event Reminder",
      "message": "Reminder: Your 'Conference' event is scheduled for tomorrow.",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "icon": Icons.notifications,
    },
  ];

  // Format the timestamp as a readable string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isNotEmpty
          ? ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon
                  Icon(
                    notification['icon'],
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 16),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification['message'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification['timestamp']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          "No new notifications",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
