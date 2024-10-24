import 'package:flutter/material.dart';
import 'GiftFormPage.dart';
import 'gift_model.dart';  // Assuming gift model is defined in a separate file

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [
    Gift(name: 'Watch', category: 'Accessories', status: 'Available'),
    Gift(name: 'Smartphone', category: 'Electronics', status: 'Pledged', isPledged: true),
    Gift(name: 'Shoes', category: 'Footwear', status: 'Available'),
  ];

  String _sortBy = 'Name'; // Default sorting criteria

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
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
          return ListTile(
            title: Text(gifts[index].name),
            subtitle: Text('Category: ${gifts[index].category}, Status: ${gifts[index].status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: gifts[index].isPledged
                      ? null // Disable editing if the gift is pledged
                      : () {
                    _editGift(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: gifts[index].isPledged
                      ? null // Disable deleting if the gift is pledged
                      : () {
                    setState(() {
                      gifts.removeAt(index); // Delete gift
                    });
                  },
                ),
              ],
            ),
            tileColor: gifts[index].isPledged
                ? Colors.greenAccent.withOpacity(0.2) // Color for pledged gifts
                : null, // Default color for non-pledged gifts
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewGift,
        child: Icon(Icons.add),
      ),
    );
  }

  // Sorting logic
  void _sortGifts() {
    setState(() {
      if (_sortBy == 'Name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'Category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortBy == 'Status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  // Add new gift function
  void _addNewGift() async {
    Gift? newGift = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GiftFormPage()),
    );
    if (newGift != null) {
      setState(() {
        gifts.add(newGift);
      });
    }
  }

  // Edit gift function
  void _editGift(int index) async {
    Gift? updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftFormPage(gift: gifts[index]),  // Pass the existing gift for editing
      ),
    );
    if (updatedGift != null) {
      setState(() {
        gifts[index] = updatedGift;
      });
    }
  }
}
