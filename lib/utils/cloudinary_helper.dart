import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryHelper {
  static Future<String?> uploadImage(File imageFile) async {
    const String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/your-cloudinary-cloud-name/image/upload';
    const String uploadPreset = 'your-upload-preset';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url']; // Image URL
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
