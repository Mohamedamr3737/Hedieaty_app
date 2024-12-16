import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:hedieaty_app/controllers/gift_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty_app/utils/imageHandler.dart';
import 'package:hedieaty_app/utils/uploadThings.dart';
import 'package:path_provider/path_provider.dart';

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

  final ImageHandler imageHandler = ImageHandler(); // Initialize handler

  void _showGiftDialog({Gift? gift}) async {
    final nameController = TextEditingController(text: gift?.name ?? '');
    final descriptionController = TextEditingController(text: gift?.description ?? '');
    final categoryController = TextEditingController(text: gift?.category ?? '');
    final priceController = TextEditingController(text: gift?.price.toString() ?? '');
    bool isPublished = gift?.published ?? false;
    String? imageLink = gift?.imageLink;

    // Select and save image locally
    String? localImagePath; // Holds the local file path

    Future<void> _selectImage({Gift? gift, Function()? updateDialogState}) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        try {
          // Save the image locally
          final directory = await getApplicationDocumentsDirectory();
          final localPath = '${directory.path}/${pickedFile.name}';
          final imageFile = File(pickedFile.path);
          await imageFile.copy(localPath);

          setState(() {
            gift?.imageLink = localPath; // Update the gift object's imageLink
            imageLink = localPath; // Update dialog's imageLink
          });

          if (updateDialogState != null) updateDialogState(); // Update dialog UI

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved locally')),
          );
        } catch (e) {
          print('Error saving image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image locally')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
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
                        ? Image.file(File(imageLink!), height: 100)
                        : Text('No image selected'),
                    TextButton.icon(
                      icon: Icon(Icons.upload),
                      label: Text('Upload Image'),
                      onPressed: () => _selectImage(
                        gift: gift,
                        updateDialogState: () => setState(() {}),
                      ),
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
                    String? finalImageLink = gift?.imageLink;

                    if (isPublished &&
                        (gift?.imageLink != null && !gift!.imageLink!.startsWith('http'))) {
                      final uploadedImageUrl =
                      await UploadService.uploadFile(File(gift.imageLink!));

                      if (uploadedImageUrl != null) {
                        finalImageLink = uploadedImageUrl;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to upload image.')),
                        );
                        return;
                      }
                    }

                    final newGift = Gift(
                      id: gift?.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      status: isPublished ? 'Published' : 'Pending',
                      published: isPublished,
                      eventId: widget.event.firestoreId,
                      firestoreId: gift?.firestoreId,
                      imageLink: finalImageLink,
                    );

                    if (gift == null) {
                      _addGift(newGift, published: isPublished ? 1 : 0);
                    } else {
                      if (isPublished) {
                        await _giftController.publishGiftToFirestore(newGift);
                      } else {
                        _updateGift(newGift);
                      }
                    }

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
                Text('Description: ${widget.event.description}'),
                Text('Location: ${widget.event.location}'),

              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gift Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: gift.imageLink != null && gift.imageLink!.startsWith('http')
                      ? Image.network(
                    gift.imageLink!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(gift.imageLink ?? ''),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),

                ),
                        SizedBox(width: 12), // Spacing between image and content

                        // Gift Details and Actions
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gift Name
                              Text(
                                gift.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),

                              // Category and Price
                              Text(
                                'Category: ${gift.category}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Text(
                                'Price: \$${gift.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 4),

                              // Live/Offline Status
                              Text(
                                gift.published ? 'Live' : 'Offline',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: gift.published ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.cloud_upload, color: Colors.blue),
                              tooltip: 'Publish Gift',
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
                                    SnackBar(content: Text(e.toString().split(':').last)),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              tooltip: 'Edit Gift',
                              onPressed: () {
                                _showGiftDialog(gift: gift);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Gift',
                              onPressed: () {
                                _deleteGift(gift.id!, firestoreId: gift.firestoreId);
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
