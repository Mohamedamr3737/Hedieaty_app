import '../models/user_model.dart';

class UserController {
  // Sign up a user
  Future<UserModel> signUpUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String repassword,
    required Map<String, dynamic> preferences,
  }) async {
    if (password != repassword) {
      throw Exception('Passwords do not match');
    }

    try {
      return await UserModel.signUpWithFirebase(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        preferences: preferences,
      );
    } catch (e) {
      throw Exception('Error signing up user: $e');
    }
  }

  // Fetch all users from SQLite
  Future<List<UserModel>> getAllUsers() async {
    try {
      return await UserModel.getUsersFromSQLite();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Log in a user
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    if (password.isEmpty) {
      throw Exception('Please enter your password.');
    }

    try {
      return await UserModel.loginWithFirebase(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
}
