import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy user information
  String _name = "John Doe";
  String _email = "johndoe@example.com";
  bool _notificationsEnabled = true;

  // Dummy data for created events and gifts
  final List<Map<String, dynamic>> _createdEvents = [
    {
      "event": "Birthday Party",
      "gifts": [
        {"name": "Watch", "status": "Available"},
        {"name": "Shoes", "status": "Pledged"}
      ]
    },
    {
      "event": "Wedding Anniversary",
      "gifts": [
        {"name": "Necklace", "status": "Available"},
        {"name": "Smartphone", "status": "Delivered"}
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Text(
              "Profile Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildUserInfoSection(),

            // Notification Settings
            SizedBox(height: 20),
            _buildNotificationSettings(),

            // User's Created Events and Gifts
            SizedBox(height: 20),
            Text(
              "Created Events and Gifts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildCreatedEvents(),

            // Link to My Pledged Gifts Page
            SizedBox(height: 20),
            _buildPledgedGiftsLink(),
          ],
        ),
      ),
    );
  }

  // Build the user info section
  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Name: $_name"),
        Text("Email: $_email"),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _updatePersonalInfo();
          },
          child: Text('Edit Personal Information'),
        ),
      ],
    );
  }

  // Build the notification settings section
  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notification Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: Text("Enable Notifications"),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  // Build the list of created events and associated gifts
  Widget _buildCreatedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _createdEvents.map((eventData) {
        return ExpansionTile(
          title: Text(eventData["event"]),
          children: (eventData["gifts"] as List<Map<String, dynamic>>)
              .map((gift) {
            return ListTile(
              title: Text(gift["name"]),
              subtitle: Text("Status: ${gift["status"]}"),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // Link to the "My Pledged Gifts" page
  Widget _buildPledgedGiftsLink() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPledgedGiftsPage()),
        );
      },
      child: Text(
        "Go to My Pledged Gifts",
        style: TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  // Dummy method to update personal info
  void _updatePersonalInfo() {
    // This could navigate to another page or show a dialog to edit user info
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

// Dummy "My Pledged Gifts" Page
class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> _pledgedGifts = [
    {"name": "Shoes", "event": "Birthday Party"},
    {"name": "Smartphone", "event": "Wedding Anniversary"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_pledgedGifts[index]['name']),
            subtitle: Text("Event: ${_pledgedGifts[index]['event']}"),
          );
        },
      ),
    );
  }
}
