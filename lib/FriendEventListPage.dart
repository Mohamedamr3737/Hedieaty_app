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
      return ListTile(
        title: Text(event['name']),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventGiftListPage(event: event),
            ),
          );
        },
      );
    },
    ),
    );
  }
}
