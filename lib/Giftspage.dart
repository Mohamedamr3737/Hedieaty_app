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
    Gift(name: 'Smartphone', category: 'Electronics', status: 'Pledged', isPledged: true, price: 799.99, imagePath: 'https://media.wired.com/photos/593284aeaef9a462de98365f/master/w_1600,c_limit/2014-09-23-iphone6-gallery-1.jpg'),
    Gift(name: 'Shoes', category: 'Footwear', status: 'Available', price: 59.99),
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
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: gifts[index].isPledged
                ? Colors.white12
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image and Gift Name
                  Row(
                    children: [
                      gifts[index].imagePath != null && gifts[index].imagePath!.isNotEmpty
                          ? Container(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            gifts[index].imagePath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : Icon(Icons.card_giftcard, size: 50),  // Default icon if no image
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          gifts[index].name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Gift Details
                  Text('Category: ${gifts[index].category}'),
                  Text('Status: ${gifts[index].status}'),
                  Text('Price: \$${gifts[index].price.toStringAsFixed(2)}'),


                  // Edit and Delete Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: gifts[index].isPledged? Icon(Icons.lock, color: Colors.blue):Icon(Icons.edit, color: Colors.blue),
                        onPressed: gifts[index].isPledged
                            ? null // Disable editing if the gift is pledged
                            : () {
                          _editGift(index);
                        },
                      ),
                      IconButton(
                        icon:gifts[index].isPledged? Icon(Icons.lock, color: Colors.blue): Icon(Icons.delete, color: Colors.red),
                        onPressed: gifts[index].isPledged
                            ? null // Disable deleting if the gift is pledged
                            : () {
                          gifts.removeAt(index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
