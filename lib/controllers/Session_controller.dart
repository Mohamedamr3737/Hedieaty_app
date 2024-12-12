import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionManager {
  static const _storage = FlutterSecureStorage();

  static const _userIdKey = 'userId';

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Retrieve user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Clear session
  static Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
  }
}
