import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:hedieaty_app/controllers/gift_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty_app/utils/cloudinary_helper.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final GiftController _giftController = GiftController();
  List<Gift> gifts = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() async {
    final fetchedGifts = await _giftController.fetchGiftsForEvent(widget.event.firestoreId!);
    setState(() {
      gifts = fetchedGifts;
    });
  }

  void _addGift(Gift gift,{int? published}) async {
    await _giftController.addGift(gift,published: published);
    _loadGifts();
  }

  void _updateGift(Gift gift) async {
    await _giftController.updateGift(gift);
    _loadGifts();
  }

  void _deleteGift(int id, {String? firestoreId}) async {
    await _giftController.deleteGift(id, firestoreId: firestoreId);
    _loadGifts();
  }

  void _showGiftDialog({Gift? gift}) async {
    final nameController = TextEditingController(text: gift?.name ?? '');
    final descriptionController = TextEditingController(text: gift?.description ?? '');
    final categoryController = TextEditingController(text: gift?.category ?? '');
    final priceController = TextEditingController(text: gift?.price.toString() ?? '');
    bool isPublished = gift?.published ?? false;
    String? imageLink = gift?.imageLink;

    void _selectImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final uploadedImageUrl = await CloudinaryHelper.uploadImage(imageFile);
        if (uploadedImageUrl != null) {
          setState(() {
            imageLink = uploadedImageUrl;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Gift Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    imageLink != null
                        ? Image.network(imageLink!, height: 100)
                        : Text('No image selected'),
                    TextButton.icon(
                      icon: Icon(Icons.upload),
                      label: Text('Upload Image'),
                      onPressed: _selectImage,
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(isPublished ? 'Unpublish Gift' : 'Publish Gift'),
                      value: isPublished,
                      onChanged: (value) {
                        setState(() {
                          isPublished = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    final newGift = Gift(
                      id: gift?.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      status: 'Pending',
                      published: isPublished,
                      eventId: widget.event.firestoreId,
                      firestoreId: gift?.firestoreId,
                      imageLink: imageLink,
                    );

                    if (gift == null) {
                      _addGift(newGift, published: isPublished?1:0);
                    } else {
                      if (isPublished && !gift.published) {
                        // Publish the gift
                        await _giftController.publishGiftToFirestore(newGift);
                      } else if (!isPublished && gift.published) {
                        // Unpublish the gift
                        await _giftController.unpublishGift(newGift);
                      } else {
                        // Simply update the gift
                        _updateGift(newGift);
                      }
                    }

                    // Reload the gifts list to reflect changes
                    _loadGifts();

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${widget.event.name}', style: TextStyle(fontSize: 18)),
                Text('Category: ${widget.event.category}'),
                Text('Date: ${widget.event.date.toLocal().toString().split(' ')[0]}'),
                Text('Status: ${widget.event.published ? 'Published' : 'Offline'}'),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return ListTile(
                  title: Text(gift.name),
                  subtitle: Text('Category: ${gift.category}, Price: \$${gift.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.cloud_upload, color: Colors.blue),
                        onPressed: () async {
                          try {
                            await _giftController.publishGiftToFirestore(gift);
                            setState(() {
                              gift.published = true; // Update local state
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gift published successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showGiftDialog(gift: gift);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteGift(gift.id!, firestoreId: gift.firestoreId);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGiftDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
