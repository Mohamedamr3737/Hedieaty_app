import 'package:flutter/material.dart';
import '../controllers/friend_controller.dart';
import '../models/user_model.dart';

class SearchFriendView extends StatefulWidget {
  final String currentUserId;

  SearchFriendView({required this.currentUserId});

  @override
  _SearchFriendViewState createState() => _SearchFriendViewState();
}

class _SearchFriendViewState extends State<SearchFriendView> {
  final FriendController _controller = FriendController();
  final TextEditingController _phoneController = TextEditingController();

  UserModel? foundFriend;
  bool isLoading = false;
  String errorMessage = '';

  // Search for a friend
  Future<void> searchFriend() async {
    setState(() {
      isLoading = true;
      foundFriend = null;
      errorMessage = '';
    });

    try {
      final friend = await _controller.searchFriend(_phoneController.text.trim());

      if (friend == null) {
        setState(() {
          errorMessage = 'No user found with this phone number.';
        });
      } else {
        setState(() {
          foundFriend = friend;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error searching for friend: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add friend
  Future<void> addFriend() async {
    if (foundFriend == null) return;

    try {
      await _controller.addFriend(widget.currentUserId, foundFriend!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend added successfully!')),
      );

      setState(() {
        foundFriend = null;
        _phoneController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    }
  }

  // Build method (essential for a StatefulWidget)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search and Add Friend')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchFriend,
              child: isLoading ? CircularProgressIndicator() : Text('Search'),
            ),
            SizedBox(height: 16),
            if (errorMessage.isNotEmpty) ...[
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
            if (foundFriend != null) ...[
              ListTile(
                leading: CircleAvatar(
                  child: Text(foundFriend!.name.isNotEmpty ? foundFriend!.name[0] : '?'),
                ),
                title: Text(foundFriend!.name),
                subtitle: Text(foundFriend!.mobile),
                trailing: ElevatedButton(
                  onPressed: addFriend,
                  child: Text('Add Friend'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
