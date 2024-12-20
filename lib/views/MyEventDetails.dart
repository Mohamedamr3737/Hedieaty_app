import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:hedieaty_app/controllers/gift_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty_app/utils/imageHandler.dart';
import 'package:hedieaty_app/utils/uploadThings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hedieaty_app/utils/image_upload_service.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final GiftController _giftController = GiftController();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<Gift> gifts = [];

  @override
  void initState() {
    super.initState();
    try {
      _RefreshGifts();
    }catch(e){
      _loadGifts();
    }
  }


  void _RefreshGifts() async {
    final gifts = await Gift.fetchGiftsForEventWithSync(widget.event.firestoreId);
    // final gifts = await _giftController.fetchGiftsForEvent(widget.event.firestoreId);
    setState(() {
      this.gifts = gifts;
    });
  }


  void _loadGifts() async {
    final gifts = await _giftController.fetchGiftsForEvent(widget.event.firestoreId);
    setState(() {
      this.gifts = gifts;
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
    // Dropdown options for status
    final List<String> statusOptions = ['Available', 'Pledged', 'Purchased'];
    String selectedStatus = gift?.status ?? 'Available';

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
                    // Dropdown for Gift Status
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(labelText: 'Status'),
                      items: statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue ?? 'Available';
                        });
                      },
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
                    String? finalImageLink = imageLink;

                    if (isPublished &&
                        (finalImageLink != null && !finalImageLink.startsWith('http'))) {

                      var uploadedImageUrl =
                      await _imageUploadService.uploadImage(File(finalImageLink));
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
                      status: selectedStatus, // Use the selected dropdown value
                      published: isPublished,
                      eventId: widget.event.firestoreId,
                      firestoreId: gift?.firestoreId,
                      imageLink: finalImageLink,
                    );


                    if (gift == null) {
                      _addGift(newGift, published: isPublished ? 1 : 0);
                    } else {
                      if (isPublished) {
                        _updateGift(newGift);
                        await _giftController.publishGiftToFirestore(newGift);

                      } else {
                        await _giftController.unpublishGift(newGift);
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
        actions: [
      IconButton(
      icon: Icon(Icons.refresh),
      tooltip: 'Refresh',
      onPressed: () {
        // Call the method to refresh events
        _RefreshGifts();
      },
      ),
        ],
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

                // Determine the card color based on the status
                Color cardColor;
                if (gift.status == 'Pledged') {
                  cardColor = Colors.green[100]!;
                } else if (gift.status == 'Purchased') {
                  cardColor = Colors.blue[100]!;
                } else {
                  cardColor = Colors.white;
                }

                return Hero(
                  tag: 'gift_${gift.firestoreId ?? gift.id ?? UniqueKey().toString()}',
                  child: Card(
                    color: cardColor, // Set the card color dynamically
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
                                ? FadeInImage.assetNetwork(
                              placeholder: 'assets/images/default_image.jpg',
                              image: gift.imageLink!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_image.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                                : gift.imageLink != null && File(gift.imageLink!).existsSync()
                                ? Image.file(
                              File(gift.imageLink!),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/images/default_image.jpg',
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

                                // Gift Status
                                Text(
                                  'Status: ${gift.status}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: gift.status == 'Pledged'
                                        ? Colors.green
                                        : gift.status == 'Purchased'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Accept/Reject Buttons for Pledged Gifts
                                if (gift.status == 'Pledged')
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          iconColor: Colors.blue, // Accept button color
                                        ),
                                        onPressed: () async {
                                          // Update status to Purchased
                                          gift.status = 'Purchased';
                                          await _giftController.updateGift(gift);
                                          setState(() {}); // Refresh UI
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gift marked as Purchased!')),
                                          );
                                        },
                                        child: Text('Accept'),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          iconColor: Colors.red, // Reject button color
                                        ),
                                        onPressed: () async {
                                          // Update status to Available
                                          gift.status = 'Available';
                                          await _giftController.updateGift(gift);
                                          setState(() {}); // Refresh UI
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gift marked as Available!')),
                                          );
                                        },
                                        child: Text('Reject'),
                                      ),
                                    ],
                                  )
                                else
                                // Action Buttons (Edit/Delete/Publish)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: gift.status == 'Purchased'
                                                ? Colors.grey // Disabled color
                                                : Colors.orange),
                                        tooltip: 'Edit Gift',
                                        onPressed: gift.status == 'Purchased'
                                            ? null // Disable button
                                            : () {
                                          _showGiftDialog(gift: gift);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: gift.status == 'Purchased'
                                                ? Colors.grey // Disabled color
                                                : Colors.red),
                                        tooltip: 'Delete Gift',
                                        onPressed: gift.status == 'Purchased'
                                            ? null // Disable button
                                            : () {
                                          _deleteGift(gift.id!, firestoreId: gift.firestoreId);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cloud_upload,
                                            color: gift.status == 'Purchased'
                                                ? Colors.grey // Disabled color
                                                : Colors.blue),
                                        tooltip: 'Publish Gift',
                                        onPressed: gift.status == 'Purchased'
                                            ? null // Disable button
                                            : () async {
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
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
