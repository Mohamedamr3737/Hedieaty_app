import 'package:flutter/material.dart';
import 'GiftFormPage.dart';
import 'gift_model.dart';  // Assuming gift model is defined in a separate file
import 'dart:io';  // For handling image files

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  // Sample list of gifts, with price and imagePath fields
  List<Gift> gifts = [
    Gift(name: 'Watch', category: 'Accessories', status: 'Available', price: 199.99),
    Gift(name: 'Smartphone', category: 'Electronics', status: 'Pledged', isPledged: true, price: 799.99, imagePath: 'path_to_smartphone_image.jpg'),
    Gift(name: 'Shoes', category: 'Footwear', status: 'Available', price: 59.99),
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
            leading: gifts[index].imagePath != null && gifts[index].imagePath!.isNotEmpty
                ? Container(
              width: 50,  // Set a fixed width
              height: 50,  // Set a fixed height
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),  // Optionally, add rounded corners
                child: Image.file(
                  File(gifts[index].imagePath!),  // Load the image
                  fit: BoxFit.cover,  // Ensure the image fits within the box
                ),
              ),
            )
                : Icon(Icons.card_giftcard, size: 50),  // Default icon if no image

            title: Text(gifts[index].name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${gifts[index].category}'),
                Text('Status: ${gifts[index].status}'),
                Text('Price: \$${gifts[index].price.toStringAsFixed(2)}'),  // Display price with 2 decimal places
              ],
            ),
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
