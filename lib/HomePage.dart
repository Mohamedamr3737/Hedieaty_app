import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Placeholder list of friends
  final List<Map<String, String>> friends = [
    {"name": "Alice", "events": "Upcoming Events: 1", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvCiFg3WKJJD9wl2z94g3-1oEAJ-Baul_GCw&s"},
    {"name": "Bob", "events": "No Upcoming Events", "image": "https://img.freepik.com/free-photo/curly-man-with-broad-smile-shows-perfect-teeth-being-amused-by-interesting-talk-has-bushy-curly-dark-hair-stands-indoor-against-white-blank-wall_273609-17092.jpg"},
    // Add more friends here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to create a new event/list screen
              },
              child: Text('Create Your Own Event/List'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friends[index]['image']!), // Load image from URL
                  ),
                  title: Text(friends[index]['name']!),
                  subtitle: Text(friends[index]['events']!),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to friend's gift list details page
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add friend functionality
        },
        child: Icon(Icons.person_add),
      ),

    );
  }
}


