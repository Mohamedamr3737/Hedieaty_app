import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_model.dart';

class Gift {
  int? id;
  String name;
  String? description;
  String category;
  double price;
  String status;
  bool published;
  String? eventId;
  String? firestoreId;
  String? imageLink;

  Gift({
    this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.status,
    this.published = false,
    required this.eventId,
    this.firestoreId,
    this.imageLink,
  });

  // Convert Gift object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'published': published ? 1 : 0,
      'event_id': eventId,
      'firestoreId': firestoreId,
      'imageLink': imageLink,
    };
  }

  // Create Gift object from SQLite Map
  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      published: map['published'] == 1,
      eventId: map['event_id'],
      firestoreId: map['firestoreId'],
      imageLink: map['imageLink'],
    );
  }

  // SQLite and Firestore communication
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Insert gift into SQLite
  static Future<int> insertGift(Map<String, dynamic> gift, {int? published}) async {
    final db = await _databaseHelper.database;

    // Step 1: Insert into SQLite
    int newId = await db.insert('Gifts', gift);

    // Step 2: Publish to Firestore if required
    if (published != null && published != 0) {
      Gift newGift = fromMap({...gift, 'id': newId}); // Create Gift object with the new ID
      await publishGiftToFirestore(newGift); // Publish to Firestore
    }

    return newId; // Return the new ID
  }

  // Fetch gifts for an event from SQLite
  static Future<List<Gift>> fetchGiftsForEvent(String? eventId) async {
    final db = await _databaseHelper.database;

    final maps = await db.query('Gifts', where: 'event_id = ?', whereArgs: [eventId]);
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  // Update gift in SQLite
  static Future<int> updateGift(int id, Map<String, dynamic> gift) async {
    final db = await _databaseHelper.database;
    final updatedGift = fromMap(gift); // Convert map to Gift object

    // If the gift is published, update Firestore
    if (updatedGift.published) {
      if (updatedGift.firestoreId != null) {
        await FirebaseFirestore.instance.collection('gifts').doc(updatedGift.firestoreId).set({
          'name': updatedGift.name,
          'description': updatedGift.description,
          'category': updatedGift.category,
          'price': updatedGift.price,
          'status': updatedGift.status,
          'published': true,
          'event_id': updatedGift.eventId,
          'imageLink': updatedGift.imageLink,
        });
      } else {
        throw Exception('Cannot update Firestore: Firestore ID is null.');
      }
    }

    // Update the gift in SQLite
    return await db.update('Gifts', gift, where: 'id = ?', whereArgs: [id]);
  }


  // Delete gift from SQLite and Firestore
  static Future<int> deleteGift(int id, {String? firestoreId}) async {
    final db = await _databaseHelper.database;

    // Delete from SQLite
    final rowsDeleted = await db.delete('Gifts', where: 'id = ?', whereArgs: [id]);

    // Delete from Firestore if `firestoreId` is provided
    if (firestoreId != null) {
      try {
        await FirebaseFirestore.instance.collection('gifts').doc(firestoreId).delete();
      } catch (e) {
        print('Failed to delete gift from Firestore: $e');
      }
    }

    return rowsDeleted;
  }

  // Publish gift to Firestore
  static Future<void> publishGiftToFirestore(Gift gift) async {
    try {
      print(gift.toMap());
      // Fetch the event associated with this gift
      final event = await Event.fetchEventById(gift.eventId);

      // Check if the event is published
      if (!event.published) {
        final giftMap = gift.toMap();
        giftMap['published'] = 0; // SQLite expects 1 for true
        await updateGift(gift.id!, giftMap); // Update the gift in SQLite
        throw Exception('Cannot publish gift: The associated event is not published.');
      }

      if (gift.firestoreId != null) {
        // Update Firestore document if `firestoreId` exists
        await FirebaseFirestore.instance.collection('gifts').doc(gift.firestoreId).set({
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status,
          'published': true,
          'event_id': gift.eventId,
          'imageLink': gift.imageLink,
        });
      } else {
        // Create a new Firestore document and retrieve its ID
        final docRef = await FirebaseFirestore.instance.collection('gifts').add({
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status,
          'published': true,
          'event_id': gift.eventId,
          'imageLink': gift.imageLink,
        });

        gift.firestoreId = docRef.id; // Assign Firestore ID to the Gift object
      }

      // Ensure `id` is not null before updating SQLite
      if (gift.id == null) {
        throw Exception('Gift ID is null. Save the gift to SQLite before publishing.');
      }

      // Update `published` status and `firestoreId` in SQLite
      gift.published = true;
      final giftMap = gift.toMap();
      giftMap['published'] = 1; // SQLite expects 1 for true
      giftMap['firestoreId'] = gift.firestoreId; // Save Firestore ID to SQLite

      await updateGift(gift.id!, giftMap); // Update the gift in SQLite
    } catch (e) {
      throw Exception('Failed to publish gift: $e');
    }
  }


  // Unpublish gift: remove from Firestore and update SQLite
  static Future<void> unpublishGift(Gift gift) async {
    try {
      if (gift.firestoreId != null) {
        // Remove from Firestore
        await FirebaseFirestore.instance.collection('gifts').doc(gift.firestoreId).delete();
      }

      // Update `published` status in SQLite to false (0)
      gift.published = false;
      final giftMap = gift.toMap();
      giftMap['published'] = 0;

      // Update the gift in SQLite
      await updateGift(gift.id!, giftMap);
    } catch (e) {
      throw Exception('Failed to unpublish gift: $e');
    }
  }

}
