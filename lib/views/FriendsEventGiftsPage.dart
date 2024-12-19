import 'package:flutter/material.dart';
import 'package:hedieaty_app/controllers/friend_controller.dart';
import '../controllers/gift_controller.dart';
import 'package:hedieaty_app/models/friend_model.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';

class EventGiftsPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  EventGiftsPage({required this.eventId, required this.eventName});

  @override
  _EventGiftsPageState createState() => _EventGiftsPageState();
}

class _EventGiftsPageState extends State<EventGiftsPage> {
  final FriendController _controller = FriendController();
  final GiftController _GiftController = GiftController();

  List<Gift> gifts = [];
  bool isLoading = true;
  String errorMessage = '';
  String? userUId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _fetchGifts();
  }
  Future<void> _initializeUser() async {
    userUId = await SecureSessionManager.getUserId();
  }
  Future<void> _fetchGifts() async {
    try {
      final fetchedGifts = await _controller.fetchGiftsForFriendsEvent(widget.eventId);
      setState(() {
        gifts = fetchedGifts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching gifts: $e';
        isLoading = false;
      });
    }
  }

  // Function to handle pledging a gift
  Future<void> _pledgeGift(String firestoreId, String? pledgedBy) async {
    try {
      await _GiftController.pledgeGift(firestoreId, pledgedBy!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift pledged successfully!')),
      );
      _fetchGifts(); // Refresh the list after updating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pledging gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.eventName} Gifts')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      )
          : gifts.isEmpty
          ? Center(
        child: Text('No gifts found for this event.'),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: gift.imageLink != null
                  ? Image.network(gift.imageLink!,
                  width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.card_giftcard, size: 40),
              title: Text(gift.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${gift.category}'),
                  Text('Price: \$${gift.price}'),
                  Text('Status: ${gift.status}'),
                ],

              ),
              trailing: gift.status == 'Pledged'
                  ? Text(
                'Pledged',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              )
                  :  gift.status == 'Purchased'?
              Text(
                'Purshased',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              )
                  :
              ElevatedButton(
                onPressed: () =>
                _pledgeGift( gift.firestoreId!, userUId ),
                child: Text('Pledge'),
              ),
            ),
          );
        },
      ),
    );
  }
}
