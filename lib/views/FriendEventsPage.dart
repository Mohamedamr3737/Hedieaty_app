import 'package:flutter/material.dart';
import '../controllers/friend_controller.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/views/FriendsEventGiftsPage.dart';
class FriendEventsPage extends StatefulWidget {
  final String friendId;
  final String friendName;

  FriendEventsPage({required this.friendId, required this.friendName});

  @override
  _FriendEventsPageState createState() => _FriendEventsPageState();
}

class _FriendEventsPageState extends State<FriendEventsPage> {
  final FriendController _controller = FriendController();
  List<Event> events = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFriendEvents();
  }

  Future<void> _fetchFriendEvents() async {
    try {
      final fetchedEvents = await _controller.fetchFriendEvents(widget.friendId);
      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching events: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friendName}\'s Events'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      )
          : events.isEmpty
          ? Center(
        child: Text(
          'No events found for ${widget.friendName}.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                event.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${event.date.toLocal()}'.split(' ')[0]),
                  Text('Location: ${event.location}'),
                  if (event.description!.isNotEmpty)
                    Text('Description: ${event.description}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventGiftsPage(
                      eventId: event.firestoreId!, // Pass eventId
                      eventName: event.name, // Pass eventName
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
