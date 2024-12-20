import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();

  // Select image and save locally
  Future<String?> selectAndSaveImageLocally() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final directory = await getApplicationDocumentsDirectory();
        final localPath = '${directory.path}/${pickedFile.name}';
        await imageFile.copy(localPath);
        return localPath; // Return the local path of the image
      }
    } catch (e) {
      print('Error selecting or saving image locally: $e');
    }
    return null;
  }

}
