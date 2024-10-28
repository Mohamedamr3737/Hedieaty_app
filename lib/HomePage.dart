import 'package:flutter/material.dart';
import 'package:hedieaty_app/FriendEventListPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> friends = [
    {
      "name": "Alice",
      "events": [
        {
          "name": "Birthday Party",
          "gifts": [
            {
              "name": "Watch",
              "category": "Accessories",
              "status": "Available",
              "price": 199.99,
              "isPledged": false,
              "imagePath": "path_to_image.jpg"
            },
            {
              "name": "Bag",
              "category": "Accessories",
              "status": "Available",
              "price": 59.99,
              "isPledged": false,
              "imagePath": "path_to_image.jpg"
            }
          ]
        },
        {
          "name": "Graduation",
          "gifts": [
            {
              "name": "Laptop",
              "category": "Electronics",
              "status": "Available",
              "price": 799.99,
              "isPledged": false,
              "imagePath": "path_to_image.jpg"
            }
          ]
        }
      ],
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvCiFg3WKJJD9wl2z94g3-1oEAJ-Baul_GCw&s"
    },
    {
      "name": "Bob",
      "events": [
        {
          "name": "Conference",
          "gifts": [
            {
              "name": "Notebook",
              "category": "Stationery",
              "status": "Available",
              "price": 9.99,
              "isPledged": false,
              "imagePath": "path_to_image.jpg"
            }
          ]
        }
      ],
      "image": "https://img.freepik.com/free-photo/curly-man-with-broad-smile-shows-perfect-teeth-being-amused-by-interesting-talk-has-bushy-curly-dark-hair-stands-indoor-against-white-blank-wall_273609-17092.jpg"
    },
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
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['image']),
                  ),
                  title: Text(friend['name']),
                  subtitle: Text(friend['events'].length > 0
                      ? 'Upcoming Events: ${friend['events'].length}'
                      : 'No Upcoming Events'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendEventListPage(friend: friend),
                      ),
                    );
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
