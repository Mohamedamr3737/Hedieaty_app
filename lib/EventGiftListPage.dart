import 'package:flutter/material.dart';
import 'dart:io';

class EventGiftListPage extends StatefulWidget {
  final Map<String, dynamic> event;

  EventGiftListPage({required this.event});

  @override
  _EventGiftListPageState createState() => _EventGiftListPageState();
}

class _EventGiftListPageState extends State<EventGiftListPage> {
  List<Map<String, dynamic>> gifts = [];
  String _sortBy = 'Name';

  @override
  void initState() {
    super.initState();
    gifts = widget.event['gifts'] as List<Map<String, dynamic>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.event['name']} Gifts'),
        actions: [
          // Dropdown for sorting gifts
          DropdownButton<String>(
            value: _sortBy,
            icon: Icon(Icons.sort),
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
                _sortGifts();
              });
            },
            items: <String>['Name', 'Category', 'Status']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by $value'),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading: gift['imagePath'] != null && gift['imagePath'].isNotEmpty
                ? Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(gift['imagePath']),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Icon(Icons.card_giftcard, size: 50),

            title: Text(gift['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${gift['category']}'),
                Text('Status: ${gift['status']}'),
                Text('Price: \$${gift['price'].toStringAsFixed(2)}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: gift['isPledged'] ? null : () => _pledgeGift(index),
              child: Text(gift['isPledged'] ? 'Pledged' : 'Pledge'),
            ),
            tileColor: gift['isPledged']
                ? Colors.greenAccent.withOpacity(0.2)
                : null,
          );
        },
      ),
    );
  }

  // Sorting logic
  void _sortGifts() {
    setState(() {
      if (_sortBy == 'Name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortBy == 'Category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (_sortBy == 'Status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

  // Pledge gift function
  void _pledgeGift(int index) {
    setState(() {
      gifts[index]['isPledged'] = true;
    });
    _notifyEventOwner(gifts[index]);
  }

  // Notify event owner function (placeholder)
  void _notifyEventOwner(Map<String, dynamic> gift) {
    print('${gift['name']} has been pledged!');
  }
}
