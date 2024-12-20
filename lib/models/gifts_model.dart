import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_model.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
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
  String? pledgeddBy;
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
    this.pledgeddBy
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
      'pledgeddBy': pledgeddBy,
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
      pledgeddBy: map['pledgeddBy']
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

  static Future<int> insertGiftToLocalOnly(Map<String, dynamic> gift, {int? published}) async {
    final db = await _databaseHelper.database;

    // Step 1: Insert into SQLite
    int newId = await db.insert('Gifts', gift);

    // // Step 2: Publish to Firestore if required
    // if (published != null && published != 0) {
    //   Gift newGift = fromMap({...gift, 'id': newId}); // Create Gift object with the new ID
    //   await publishGiftToFirestore(newGift); // Publish to Firestore
    // }

    return newId; // Return the new ID
  }


  /////
  static Future<List<Gift>> fetchGiftsForEventWithSync(String? eventId) async {
    print("pressed");
    // Step 1: Fetch gifts from SQLite
    final localGifts = await Gift.fetchGiftsForEvent(eventId);

    // Step 2: Try fetching gifts from Firestore
    List<Gift> firestoreGifts = [];
    try {
      firestoreGifts = await FirebaseFirestore.instance
          .collection('gifts')
          .where('event_id', isEqualTo: eventId)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        print("frommmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
        print(data);
        return Gift(
          name: data['name'],
          description: data['description'],
          category: data['category'],
          price: data['price'],
          status: data['status'],
          published: data['published'] ?? false,
          eventId: data['event_id'],
          firestoreId: doc.id,
          imageLink: data['imageLink'],
          pledgeddBy: data['pledgedBy']
        );
      }).toList());
    } catch (e) {
      print('Firestore fetch failed: $e'); // Log the error
      // Proceed with local data only
    }

    // Step 3: Sync Firestore gifts to SQLite if available
    if (firestoreGifts.isNotEmpty) {
      for (var firestoreGift in firestoreGifts) {
        final existingGift = localGifts.firstWhereOrNull(
              (localGift) => localGift.firestoreId == firestoreGift.firestoreId,
        );

        if (existingGift == null) {
          // Insert new gift into SQLite
          await Gift.insertGiftToLocalOnly(firestoreGift.toMap());
        } else {
          // Optionally update the local gift if Firestore gift is newer
          await Gift.updateGiftToLocalOnly(existingGift.id!, firestoreGift.toMap());
        }
      }
    }

    // Step 4: Fetch updated local gifts from SQLite
    final updatedLocalGifts = await Gift.fetchGiftsForEvent(eventId);

    // Step 5: Return combined list of gifts
    return updatedLocalGifts;
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
          'pledgedBy': updatedGift.pledgeddBy,
        });
      } else {
        throw Exception('Cannot update Firestore: Firestore ID is null.');
      }
    }
    final updatedGift2 = Map<String, dynamic>.from(gift);
    updatedGift2.remove('id');
    // Update the gift in SQLite
    return await db.update('Gifts', updatedGift2, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateGiftToLocalOnly(int id, Map<String, dynamic> gift) async {
    final db = await _databaseHelper.database;

    final updatedGift2 = Map<String, dynamic>.from(gift);
    updatedGift2.remove('id');
    // Update the gift in SQLite
    return await db.update('Gifts', updatedGift2, where: 'id = ?', whereArgs: [id]);
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
          'pledgedBy':gift.pledgeddBy??"no user yet",
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
          'pledgedBy':gift.pledgeddBy??"no user yet",
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

  // Update gift status in Firestore
  static Future<void> updateGiftStatus(String firestoreId, String newStatus, String pledgedBy) async {
    try {
      print(pledgedBy);
      await FirebaseFirestore.instance
          .collection('gifts')
          .doc(firestoreId)
          .set({
        'status': newStatus,
        'pledgedBy': pledgedBy, // Include this field to ensure it is not removed
      }, SetOptions(merge: true)); // Use merge: true to prevent overwriting other fields

    } catch (e) {
      throw Exception('Error updating gift status: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMyPledgedIWillBuy(String userId) async {
    try {
      // Fetch pledged gifts by the user
      QuerySnapshot pledgedGiftsSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('pledgedBy', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> pledgedGifts = pledgedGiftsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      if (pledgedGifts.isEmpty) {
        return [];
      }

      // Extract event IDs
      Set<String> eventIds = pledgedGifts.map((gift) => gift['event_id'] as String).toSet();

      // Fetch events
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIds.toList())
          .get();

      Map<String, dynamic> eventDetails = {
        for (var doc in eventsSnapshot.docs)
          doc.id: {
            'date': (doc.data() as Map<String, dynamic>)['date'] ?? 'Unknown',
            'user_id': (doc.data() as Map<String, dynamic>)['user_id'] ?? 'Unknown',
          }
      };

      // Fetch user details of event creators
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId,
          whereIn: eventDetails.values.map((e) => e['user_id']).toSet().toList())
          .get();

      Map<String, String> userDetails = {
        for (var doc in usersSnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
      };

      // Map gifts to include recipient name and event deadline
      List<Map<String, dynamic>> allGifts = pledgedGifts.map((gift) {
        String eventId = gift['event_id'];
        String recipientId = eventDetails[eventId]?['user_id'] ?? 'Unknown';

        // Format the deadline
        String deadline = 'Unknown';
        if (eventDetails[eventId]?['date'] != null &&
            eventDetails[eventId]['date'].toString().isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(eventDetails[eventId]['date']);
            deadline = DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            print('Error parsing date for event ID $eventId: $e');
          }
        }

        return {
          ...gift,
          'Deadline': deadline, // Include formatted event deadline
          'RecipientName': userDetails[recipientId] ?? 'Unknown', // Include recipient's name
        };
      }).toList();

      return allGifts;
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }



  static Future<List<Map<String, dynamic>>> fetchMyPledgedBoughtToMe(String userId) async {
    try {
      // Fetch events created by the user
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> events = eventsSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();

      // Extract event IDs and map them with their dates
      Map<String, dynamic> eventDetails = {
        for (var event in events)
          event['id']: {
            'date': event['date'], // Assuming 'date' is the event deadline
          }
      };

      if (eventDetails.isEmpty) {
        return [];
      }

      // Fetch gifts associated with the events
      QuerySnapshot eventGiftsSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('event_id', whereIn: eventDetails.keys.toList())
          .where('status', whereIn: ['Pledged', 'Purchased'])
          .get();

      // Extract `pledgedBy` user IDs
      Set<String> userIds = eventGiftsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['pledgedBy'] as String)
          .toSet();

      // Fetch user details for the `pledgedBy` users
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      Map<String, String> userDetails = {
        for (var doc in usersSnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
      };

      // Map the gifts to include the pledger's name and event deadline
      List<Map<String, dynamic>> eventGifts = eventGiftsSnapshot.docs.map((doc) {
        Map<String, dynamic> giftData = doc.data() as Map<String, dynamic>;
        String eventId = giftData['event_id'];
        String pledgedById = giftData['pledgedBy'];

        // Format the deadline
        String deadline = 'Unknown';
        if (eventDetails[eventId]?['date'] != null &&
            eventDetails[eventId]['date'].toString().isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(eventDetails[eventId]['date']);
            deadline = DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            print('Error parsing date for event ID $eventId: $e');
          }
        }

        return {
          'id': doc.id,
          ...giftData,
          'Deadline': deadline, // Include the formatted deadline
          'PledgedByName': userDetails[pledgedById] ?? 'Unknown', // Add the pledger's name
        };
      }).toList();

      return eventGifts;
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }



}
