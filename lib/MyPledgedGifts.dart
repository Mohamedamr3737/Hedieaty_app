import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> _pledgedGifts = [
    {
      "name": "Shoes",
      "event": "Birthday Party",
      "friendName": "Alice",
      "dueDate": DateTime.now().add(Duration(days: 5)), // 5 days from today
      "isPending": true,
    },
    {
      "name": "Smartphone",
      "event": "Wedding Anniversary",
      "friendName": "Bob",
      "dueDate": DateTime.now().subtract(Duration(days: 3)), // 3 days ago
      "isPending": false,
    },
  ];

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(gift['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Event: ${gift['event']}"),
                  Text("Friend: ${gift['friendName']}"),
                  Text("Due Date: ${_formatDate(gift['dueDate'])}"),
                  Text(
                    "Status: ${gift['isPending'] ? 'Pending' : 'Completed'}",
                    style: TextStyle(
                      color: gift['isPending'] ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: gift['isPending']
                  ? IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // Navigate to edit page or perform edit action if pending
                  _modifyPledgedGift(context, gift);
                },
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _modifyPledgedGift(BuildContext context, Map<String, dynamic> gift) {
    // Functionality to modify pledged gift details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modify Pledged Gift"),
        content: Text("Modify the details for ${gift['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Implement modification logic here
              Navigator.pop(context);
            },
            child: Text("Modify"),
          ),
        ],
      ),
    );
  }
}
