import 'package:flutter/material.dart';
import 'gift_model.dart';  // Assuming gift model is defined in another file
import 'package:image_picker/image_picker.dart';
import 'dart:io';  // For handling File type

class GiftFormPage extends StatefulWidget {
  final Gift? gift;  // Existing gift if editing

  GiftFormPage({this.gift});

  @override
  _GiftFormPageState createState() => _GiftFormPageState();
}

class _GiftFormPageState extends State<GiftFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _status;
  late double _price;
  File? _selectedImage;  // Image file

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      _name = widget.gift!.name;
      _category = widget.gift!.category;
      _status = widget.gift!.status;
      _price = widget.gift!.price;
      if (widget.gift!.imagePath != null) {
        _selectedImage = File(widget.gift!.imagePath!);
      }
    } else {
      _name = '';
      _category = 'Accessories';
      _status = 'Available';
      _price = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gift name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: 'Category'),
                  onSaved: (value) => _category = value!,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ['Available', 'Pledged', 'Delivered'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _status = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextFormField(
                  initialValue: _price.toString(),
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _price = double.parse(value!),
                ),
                SizedBox(height: 20),
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 200, width: 200)  // Display selected image
                    : Text('No image selected'),
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Select Image'),
                  onPressed:  _pickImage,  // Select image button
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final newGift = Gift(
                        name: _name,
                        category: _category,
                        status: _status,
                        price: _price,
                        isPledged: _status == 'Pledged',
                        imagePath: _selectedImage?.path,  // Save the image path
                      );
                      Navigator.pop(context, newGift);  // Return new/edited gift
                    }
                  },
                  child: Text(widget.gift == null ? 'Add Gift' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);  // Update the selected image
      });
    }
  }
}
