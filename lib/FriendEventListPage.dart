import 'package:flutter/material.dart';
import 'package:hedieaty_app/EventGiftListPage.dart';

class FriendEventListPage extends StatelessWidget {
  final Map<String, dynamic> friend;

  FriendEventListPage({required this.friend});

  @override
  Widget build(BuildContext context) {
    final events = friend['events'] as List<Map<String, dynamic>>;
    return Scaffold(
        appBar: AppBar(title: Text('${friend['name']}s Events')),
        body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
      final event = events[index];
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventGiftListPage(event: event),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Event Name
                Text(
                  event['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Arrow Icon
                Icon(Icons.arrow_forward_ios),
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
