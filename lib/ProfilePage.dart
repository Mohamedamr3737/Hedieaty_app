import 'package:flutter/material.dart';
import 'package:hedieaty_app/MyPledgedGifts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy user information
  String _name = "Mohamed Amr";
  String _email = "mohamedamr@example.com";
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
            // Profile Photo and User Information Section
            Center(child: _buildProfilePhoto()),
            SizedBox(height: 16),
            Center(child: _buildUserInfoSection()),

            // Notification Settings
            SizedBox(height: 30),
            _buildNotificationSettings(),

            // User's Created Events and Gifts
            SizedBox(height: 30),
            Text(
              "Created Events and Gifts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildCreatedEvents(),

            // Link to My Pledged Gifts Page
            SizedBox(height: 30),
            _buildPledgedGiftsLink(),
          ],
        ),
      ),
    );
  }

  // Build the profile photo section
  Widget _buildProfilePhoto() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://cdn.create.vista.com/api/media/small/133960224/stock-photo-smiling-young-man'), // Replace with user's profile image URL
        ),
        SizedBox(height: 10),
        Text(
          _name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          _email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Build the user info section
  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _updatePersonalInfo();
          },
          child: Text('Edit Personal Information'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: ExpansionTile(
            title: Text(
              eventData["event"],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            children: (eventData["gifts"] as List<Map<String, dynamic>>).map((gift) {
              return ListTile(
                title: Text(gift["name"]),
                subtitle: Text("Status: ${gift["status"]}"),
              );
            }).toList(),
          ),
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
      child: Center(
        child: Text(
          "Go to My Pledged Gifts",
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Dummy method to update personal info
  void _updatePersonalInfo() {
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
