import 'package:flutter/material.dart';
import 'package:hedieaty_app/views/MyPledgedGifts.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
import 'package:hedieaty_app/controllers/user_controller.dart';
import 'package:hedieaty_app/models/user_model.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy user information
  String _name = "";
  String _email = "";
  bool _notificationsEnabled = true;
  // Data for events and associated gifts
  List<Map<String, dynamic>> _eventsWithGifts = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEventsAndGifts();

  }

  Future<void> _loadUserData() async {
  String? userId = await SecureSessionManager.getUserId(); // Replace with actual user ID
  try {
  UserModel user = await UserController.fetchUser(userId!);
  setState(() {
  _name = user.name;
  _email = user.email;
  });
  } catch (e) {
  print('Error loading user data: $e');
  }
  }

  // Function to fetch events and associated gifts
  Future<void> _loadEventsAndGifts() async {
    String? userId = await SecureSessionManager.getUserId(); // Replace with the actual user ID
    List<Map<String, dynamic>> data = await fetchEventsAndGiftsForProfile(userId!);
    setState(() {
      _eventsWithGifts = data;
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchEventsAndGiftsForProfile(String userId) async {
    List<Map<String, dynamic>> eventsWithGifts = [];

    try {
      // Step 1: Fetch all events created by the user
      List<Event> events = await Event.fetchEvents(userId);

      // Step 2: For each event, fetch its associated gifts
      for (Event event in events) {
        List<Gift> gifts = await Gift.fetchGiftsForEventWithSync(event.firestoreId);

        // Step 3: Combine event and gifts into a single map
        eventsWithGifts.add({
          "event": event,
          "gifts": gifts,
        });
      }
    } catch (e) {
      print('Error fetching events and gifts: $e');
    }

    return eventsWithGifts;
  }

  Future<void> _logout() async {
    try {
      await SecureSessionManager.clearSession(); // Clear session
      Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login screen
    } catch (e) {
      print('Error during logout: $e');
      // Optionally, show a Snackbar or dialog with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              setState(() {
                _isLoading = true; // Show loading indicator
              });
              await _loadUserData();
              await _loadEventsAndGifts();
              setState(() {
                _isLoading = false; // Hide loading indicator
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo and User Information Section
            Center(child: _buildProfilePhoto()),
            SizedBox(height: 16),

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
          backgroundColor: Colors.blue, // Set a background color
          child: Icon(
            Icons.person, // Replace with your desired icon
            size: 50,     // Adjust the size of the icon
            color: Colors.white, // Adjust the color of the icon
          ),
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_eventsWithGifts.isEmpty) {
      return Center(child: Text("No events or gifts found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _eventsWithGifts.map((eventData) {
        final Event event = eventData["event"];
        final List<Gift> gifts = eventData["gifts"];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: ExpansionTile(
            title: Text(
              event.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(event.description ?? ""),
            children: gifts.map((gift) {
              return ListTile(
                title: Text(gift.name),
                subtitle: Text("Status: ${gift.status}"),
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
