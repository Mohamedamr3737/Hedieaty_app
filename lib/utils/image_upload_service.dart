import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uploadthing/uploadthing.dart';

class ImageUploadService {
  static const String _apiKey =
      "sk_live_c5d1269ffd8f9eb324f4816f068ffcfd132ac4a84b16740433c50b0515eee3f0";

  final UploadThing _uploadThing = UploadThing(_apiKey);


  /// Upload the selected image
  Future<String?> uploadImage(File imageFile) async {
    try {
      final List<File> files = [imageFile];
      final response = await _uploadThing.uploadFiles(files);

      if (response) {
        final uploadedUrl = _uploadThing.uploadedFilesData.last;
        print("frommmmmmmmmmmmm");
        print(uploadedUrl['url']);
        return uploadedUrl['url'];
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return "";
  }
}
