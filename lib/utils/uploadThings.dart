import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  static const String apiKey = "sk_live_c5d1269ffd8f9eb324f4816f068ffcfd132ac4a84b16740433c50b0515eee3f0";
  static const String uploadUrl = "https://uploadthing.com/api/upload";

  // Upload image to UploadThing
  static Future<String?> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));

      // Add API key and content type
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Attach file to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        final fileUrl = decodedData['fileUrl']; // Extract file URL

        return fileUrl; // Return uploaded file URL
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
