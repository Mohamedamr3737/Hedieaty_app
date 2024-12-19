import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/database//database_helper.dart';
import 'package:sqflite/sql.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class FriendModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Search for a friend by phone number in Firestore
  Future<Map<String, dynamic>?> searchByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No user found
      }

      // Fetch the first document and add the document ID to the data
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['uid'] = doc.id; // Include the document ID as 'uid'

      return data; // Return the updated data map
    } catch (e) {
      throw Exception('Error searching friend by phone: $e');
    }
  }


  // Add friend in Firestore
  Future<void> addFriendToFirestore(String currentUserId, String friendId) async {
    try {
      // Update the current user's friends list
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Update the friend's friends list
      await _firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      throw Exception('Error adding friend to Firestore: $e');
    }
  }

  // Save friend locally in SQLite
  Future<void> saveFriendToLocal(String userId, String friendId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'friends',
      {'user_id': userId, 'friend_id': friendId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch the friends' IDs of a specific user
  Future<List<String>> getFriendsList(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return List<String>.from(docSnapshot.data()?['friends'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching friends list: $e');
    }
  }

  // Fetch friends' details based on IDs
  Future<List<Map<String, dynamic>>> getFriendsDetails(List<String> friendIds) async {
    try {
      if (friendIds.isEmpty) return [];

      final friendsQuery = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      return friendsQuery.docs.map((doc) => {
        'uid': doc.id,
        'name': doc['name'] ?? 'Unknown',
        'mobile': doc['mobile'] ?? 'No Phone',
        'image':  '', // Optional field for avatar
      }).toList();
    } catch (e) {
      throw Exception('Error fetching friends details: $e');
    }
  }

  // Fetch friends' details and their event count based on day
  Future<List<Map<String, dynamic>>> getFriendsDetailsWithEvents(List<String> friendIds) async {
    try {
      if (friendIds.isEmpty) return [];

      // Fetch friends' details
      final friendsQuery = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      List<Map<String, dynamic>> friends = [];

      // Format today's date as YYYY-MM-DD
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // For each friend, fetch their event count
      for (var doc in friendsQuery.docs) {
        final friendData = {
          'uid': doc.id,
          'name': doc['name'] ?? 'Unknown',
          'mobile': doc['mobile'] ?? '',
          'image':  '',
        };

        // Fetch the count of upcoming events for this friend (only by day)
        final eventsQuery = await _firestore
            .collection('events')
            .where('user_id', isEqualTo: doc.id)
            .get();

        // Filter events where the 'date' field matches or is greater than today
        int eventCount = eventsQuery.docs
            .where((event) {
          final eventDate = event['date'] ?? '';
          if (eventDate is String) {
            return eventDate.compareTo(today) >= 0;
          }
          return false;
        })
            .length;

        friendData['eventCount'] = eventCount;

        friends.add(friendData);
      }

      return friends;
    } catch (e) {
      throw Exception('Error fetching friends with events: $e');
    }
  }


}
