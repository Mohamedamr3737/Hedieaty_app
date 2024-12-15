import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
class UserModel {

  String uid; // Firebase UID
  String name;
  String email;
  String mobile;
  String preferences; // JSON string for user preferences

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobile,
    this.preferences = '',
  });

  // Convert UserModel to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'mobile':mobile,
      'email': email,
      'preferences': preferences,
    };
  }

  // Create UserModel from a Map fetched from SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      mobile: map['mobile'],
      email: map['email'],
      preferences: map['preferences'] ?? '',
    );
  }

  // Parse preferences JSON string into a Map
  Map<String, dynamic> getPreferences() {
    return preferences.isNotEmpty ? jsonDecode(preferences) : {};
  }

  // Set preferences as a JSON string
  void setPreferences(Map<String, dynamic> prefs) {
    preferences = jsonEncode(prefs);
  }

  // Save user data to Firestore
  static Future<void> saveToFirestore(UserModel user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(user.uid).set({
        'name': user.name,
        'email': user.email,
        'mobile':user.mobile,
        'preferences': user.getPreferences(),
      });
    } catch (e) {
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(e);
      throw Exception('Error saving user to Firestore: $e');
    }
  }

  // Save user data to SQLite
  static Future<int> saveToSQLite(UserModel user) async {
    final db = await DatabaseHelper().database;
    return await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all users from SQLite database
  static Future<List<UserModel>> getUsersFromSQLite() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('Users'); // Query the Users table
    return result.map((map) => UserModel.fromMap(map)).toList(); // Convert to UserModel list
  }

  static Future<UserModel> signUpWithFirebase({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      print('Starting Firebase signup...');

      // Create user with Firebase Authentication
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Authentication successful. Credential: ${credential.user}');

      // Extract the Firebase user
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null after sign-up.');
      }

      // Create UserModel instance
      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        mobile: mobile,
      );
      user.setPreferences(preferences);

      // Save user data to Firestore
      await saveToFirestore(user);
      print('Data saved to Firestore successfully.');

      // Save user data to SQLite
      await saveToSQLite(user);
      print('Data saved to SQLite successfully.');

      return user; // Return user on success
    } catch (e) {
      print('Error in signUpWithFirebase: $e');
      throw Exception('Error signing up with Firebase: $e');
    }
  }

  // Firebase Login Method
  static Future<UserModel> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting Firebase login...');

      // Perform Firebase login
      final UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Authentication successful. Credential: ${credential.user}');

      // Extract user data from Firebase
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null after login.');
      }

      // Retrieve user data from Firestore
      final userData = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      await SecureSessionManager.saveUserId(firebaseUser.uid);

      if (!userData.exists) {
        throw Exception('User data not found in Firestore.');
      }

      final data = userData.data()!;
      final user = UserModel(
        uid: firebaseUser.uid,
        name: data['name'] ?? '',
        email: data['email'] ?? email,
        mobile: data['mobile'] ?? '',
        preferences: jsonEncode(data['preferences'] ?? {}),
      );

      print('User data retrieved successfully: ${user.toMap()}');

      // Check if the user already exists in SQLite
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'Users',
        where: 'uid = ?',
        whereArgs: [user.uid],
      );

      if (result.isEmpty) {
        // Save the user to SQLite if not found
        print('User not found in SQLite. Saving user...');
        await saveToSQLite(user);

        print('User saved to SQLite successfully.');
      } else {
        print('User already exists in SQLite.');
      }

      return user;
    } catch (e) {
      print('Error in loginWithFirebase: $e');
      throw Exception('Error logging in with Firebase: $e');
    }
  }

  // Function to get the current user UID from SQLite
  static Future<String?> getCurrentUserId() async {
    try {
      final db = await DatabaseHelper().database;

      // Query the Users table to get the current user
      // Assuming you have a 'current_user' flag or a similar mechanism
      final List<Map<String, dynamic>> result = await db.query(
        'Users',
        where: 'is_logged_in = ?', // Adjust the condition as per your schema
        whereArgs: [1], // Assuming 1 indicates the currently logged-in user
        limit: 1,
      );

      if (result.isNotEmpty) {
        // Extract and return the UID of the current user
        return result.first['uid'] as String?;
      } else {
        // No user found
        return null;
      }
    } catch (e) {
      print('Error fetching current user UID: $e');
      return null;
    }
  }



}
