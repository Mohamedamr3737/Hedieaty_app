import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty_app/utils/image_upload_service.dart';

void main() {
  runApp(UploadTestApp());
}

class UploadTestApp extends StatefulWidget {
  @override
  _UploadTestAppState createState() => _UploadTestAppState();
}

class _UploadTestAppState extends State<UploadTestApp> {
  final ImageUploadService _imageUploadService = ImageUploadService();

  File? _selectedImage;
  String? _uploadedImageUrl;

  /// Select an image from the gallery
  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('Image selected: ${_selectedImage!.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  /// Upload the image via the service
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      print('No image selected to upload.');
      return;
    }

    try {
      // Delegate upload to the service
      final response = await _imageUploadService.uploadImage(_selectedImage!);

      if (response.isNotEmpty && response['url'] != null) {
        setState(() {
          _uploadedImageUrl = response['url'];
        });
        print('Image uploaded successfully: $_uploadedImageUrl');
      } else {
        print('Failed to upload the image.');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Upload Module'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
                  : Text('No image selected'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('Select Image'),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Image'),
              ),
              SizedBox(height: 20),
              _uploadedImageUrl != null
                  ? SelectableText(
                'Uploaded Image URL: $_uploadedImageUrl',
                style: TextStyle(color: Colors.green),
              )
                  : Text('No image uploaded'),
            ],
          ),
        ),
      ),
    );
  }
}
