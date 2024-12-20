import 'package:flutter/material.dart';
import 'package:hedieaty_app/controllers/gift_controller.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
import 'package:hedieaty_app/controllers/gift_controller.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final GiftController _giftController = GiftController();

  List<Map<String, dynamic>> pledgedBoughtToMe = [];
  List<Map<String, dynamic>> pledgedIWillBuy = [];
  bool isLoading = true;
  String errorMessage = '';
  String? userUId;

  @override
  void initState() {
    super.initState();
    _initializeUserAndFetchGifts();
  }

  Future<void> _initializeUserAndFetchGifts() async {
    try {
      userUId = await SecureSessionManager.getUserId();

      if (userUId != null) {
        final boughtToMe = await _giftController.FetchMyPledgedBoughtToMe(userUId!);
        final iWillBuy = await _giftController.FetchMyPledgedIWillBuy(userUId!);

        setState(() {
          pledgedBoughtToMe = boughtToMe;
          pledgedIWillBuy = iWillBuy;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'User not logged in.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching gifts: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
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
          : ListView(
        children: [
          if (pledgedBoughtToMe.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gifts Pledged to Me',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...pledgedBoughtToMe.map((gift) => _buildGiftCard(gift)),
          ],
          if (pledgedIWillBuy.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gifts I Will Buy',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...pledgedIWillBuy.map((gift) => _buildGiftCard(gift)),
          ],
          if (pledgedBoughtToMe.isEmpty && pledgedIWillBuy.isEmpty)
            Center(
              child: Text('No pledged gifts found.'),
            ),
        ],
      ),
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: gift['imageLink'] != null
            ? Image.network(gift['imageLink'],
            width: 50, height: 50, fit: BoxFit.cover)
            : Icon(Icons.card_giftcard, size: 40),
        title: Text(gift['name'] ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${gift['category'] ?? 'N/A'}'),
            Text('Price: \$${gift['price'] ?? 'N/A'}'),
            Text('Status: ${gift['status'] ?? 'N/A'}'),
            Text('Deadline: ${gift['Deadline'] ?? 'N/A'}'),
            gift['PledgedByName'] != null && gift['PledgedByName'].isNotEmpty
                ? Text('Pledged By: ${gift['PledgedByName']}')
                : SizedBox.shrink(),
            gift['RecipientName'] != null && gift['RecipientName'].isNotEmpty
                ? Text('Recipient Name: ${gift['RecipientName']}')
                : SizedBox.shrink(),
          ],
        ),

        trailing: gift['status'] == 'Purchased'
            ? Text(
          'Purchased',
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold),
        )
            : Text(
          'Pledged',
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
