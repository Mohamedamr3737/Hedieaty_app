
import 'package:flutter/material.dart';
import 'package:hedieaty_app/controllers/friend_controller.dart';
import 'package:hedieaty_app/views/search_friend_view.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
import 'package:hedieaty_app/views/FriendEventsPage.dart';
class HomePage extends StatefulWidget {
  // final String currentUserId;

  // HomePage({required this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FriendController _controller = FriendController();

  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  // Fetch friends list
  Future<void> _fetchFriends() async {
    try {
      String? currentUserId= await SecureSessionManager.getUserId();
      print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      print(currentUserId);
      final fetchedFriends = await _controller.fetchFriendsWithEvents(currentUserId!);
      setState(() {
        friends = fetchedFriends;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching friends: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchFriends, // Refresh the friends list
            tooltip: 'Refresh Friends List',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading spinner
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : friends.isEmpty
          ? Center(
        child: Text(
          'No friends added yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return
          Hero(tag: friend['uid'],
          child:
            Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: false
                      ? NetworkImage(friend['image'])
                      : null,
                  child: true
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey[400],
                ),
                title: Text(friend['name']),
                subtitle: Text('Upcoming Events: ${friend['eventCount']}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to FriendEventsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendEventsPage(
                        friendId: friend['uid'],
                        friendName: friend['name'],
                      ),
                    ),
                  );
                },
              ),

          ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? UID= await SecureSessionManager.getUserId();
          print("wewewewewewewwwwwwwwwwwwwwwww");
          print(UID);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchFriendView(currentUserId: UID!  ),
            ),
          );
        },
        child: Icon(Icons.person_add),
        tooltip: 'Add Friend',
      ),
    );
  }
}

