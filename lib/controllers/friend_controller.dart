import '../models/friend_model.dart';
import '../models/user_model.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/models/gifts_model.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:hedieaty_app/database/database_helper.dart';
class FriendController {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FriendModel _model = FriendModel();

  // Search for a friend by phone number
  Future<UserModel?> searchFriend(String phoneNumber) async {
    try {
      final data = await _model.searchByPhone(phoneNumber);

      if (data == null) return null; // No user found

      return UserModel(
        uid: data['uid'],
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        mobile: data['mobile'] ?? '',
        // preferences: '',
      );
    } catch (e) {
      throw Exception('Error searching friend: $e');
    }
  }

  // Add a friend
  Future<void> addFriend(String currentUserId, UserModel friend) async {
    try {
      // Add to Firestore
      await _model.addFriendToFirestore(currentUserId, friend.uid);

      // Save locally in SQLite
      await _model.saveFriendToLocal(currentUserId, friend.uid);
    } catch (e) {
      throw Exception('Error adding friend: $e');
    }
  }

  // Fetch complete friends list for a user
  Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
    try {
      // Step 1: Fetch friend IDs
      List<String> friendIds = await _model.getFriendsList(userId);

      // Step 2: Fetch friends' details based on IDs
      return await _model.getFriendsDetails(friendIds);
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }

  // Fetch friends and their upcoming event counts
  Future<List<Map<String, dynamic>>> fetchFriendsWithEvents(String userId) async {
    try {
      List<String> friendIds = await _model.getFriendsList(userId);
      return await _model.getFriendsDetailsWithEvents(friendIds);
    } catch (e) {
      throw Exception('Error fetching friends and events: $e');
    }
  }

  // Fetch events for a specific friend
  Future<List<Event>> fetchFriendEvents(String friendId) async {
    try {
      return await Event.fetchEvents(friendId);
    } catch (e) {
      throw Exception('Error fetching events for friend: $e');
    }
  }

  // Fetch gifts for an event with synchronization
  Future<List<Gift>> fetchGiftsForFriendsEvent(String eventId) async {
    try {
      return await Gift.fetchGiftsForEventWithSync(eventId);
    } catch (e) {
      throw Exception('Error fetching gifts for event: $e');
    }
  }


}
