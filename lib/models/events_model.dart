import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hedieaty_app/models/gifts_model.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Event {
  int? id;
  String name;
  DateTime date;
  String? location;
  String? description;
  String? category;
  bool published;
  String? userId;
  String? firestoreId;

  Event({
    this.id,
    required this.name,
    required this.date,
    this.location,
    this.description,
    this.category,
    this.published = false,
    required this.userId,
    required this.firestoreId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'category': category,
      'published': published ? 1 : 0,
      'user_id': userId,
      'firestore_id':firestoreId,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      category: map['category'],
      published: map['published'] == 1,
      userId: map['user_id'],
      firestoreId: map['firestore_id'],
    );
  }

  // Database operations through the model
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<int> insertEvent(Map<String, dynamic> event, {int? published}) async {
    final db = await _databaseHelper.database;

    // Step 1: Insert event into SQLite and get the generated ID
    int newId = await db.insert('Events', event);

    // Step 2: Publish the event if it should be published
    if (published == 1) {
      final newEvent = Event.fromMap({...event, 'id': newId});
      await publishEventToFirestore(newEvent);
    }

    return newId;
  }


  static Future<List<Event>> fetchEventsForUser(String? userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('Events', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((map) => Event.fromMap(map)).toList();
  }



  static Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await _databaseHelper.database;
    event.remove('id');
    return await db.update('Events', event, where: 'id = ?', whereArgs: [id]);
  }

  // static Future<int> deleteEvent(int id, {String? firestoreId}) async {
  //   final db = await _databaseHelper.database;
  //
  //   // Delete from SQLite
  //   final rowsDeleted = await db.delete(
  //     'Events',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //
  //   // Delete from Firestore if `firestoreId` is provided
  //   if (firestoreId != null) {
  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('events')
  //           .doc(firestoreId)
  //           .delete();
  //     } catch (e) {
  //       print('Failed to delete event from Firestore: $e');
  //     }
  //   }
  //
  //   return rowsDeleted;
  // }


  static Future<void> publishEventToFirestore(Event event) async {
    try {
      if (event.id == null) {
        throw Exception('Event ID is null. Save the event to SQLite before publishing.');
      }

      // Create or update the Firestore document
      if (event.firestoreId != null) {
        // Update existing Firestore document
        await _firestore.collection('events').doc(event.firestoreId).set({
          'name': event.name,
          'date': event.date.toIso8601String(),
          'location': event.location,
          'description': event.description,
          'category': event.category,
          'published': true,
          'user_id': event.userId,
        });
      } else {
        // Create a new Firestore document
        final docRef = await _firestore.collection('events').add({
          'name': event.name,
          'date': event.date.toIso8601String(),
          'location': event.location,
          'description': event.description,
          'category': event.category,
          'published': true,
          'user_id': event.userId,
        });

        // Save the Firestore document ID in the event object
        event.firestoreId = docRef.id;
      }

      // Ensure the `published` field is set to 1
      event.published = true;

      // Update the SQLite record with the new Firestore ID and `published` status
      final updatedEventMap = event.toMap();
      updatedEventMap['published'] = 1; // Explicitly set published to 1
      await updateEvent(event.id!, updatedEventMap);
    } catch (e) {
      throw Exception('Failed to publish event: $e');
    }
  }



  static Future<void> unpublishEventFromFirestore(String? firestoreId) async {
    try {
      if (firestoreId != null) {
        await _firestore.collection('events').doc(firestoreId).delete();
      }
    } catch (e) {
      throw Exception('Failed to unpublish event: $e');
    }
  }

  static Future<List<Event>> fetchEvents(String? userId) async {
    // Fetch events from SQLite
    final localEvents = await Event.fetchEventsForUser(userId);

    // Fetch events from Firestore
    final firestoreEvents = await _firestore
        .collection('events')
        .where('user_id', isEqualTo: userId)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Event(
        id: null, // No local ID
        name: data['name'],
        date: DateTime.parse(data['date']),
        location: data['location'],
        description: data['description'],
        category: data['category'],
        published: data['published'] ?? false,
        userId: data['user_id'],
        firestoreId: doc.id,
      );
    }).toList());

    // Save Firestore events to SQLite
    for (var event in firestoreEvents) {
      final existingEvent = localEvents.firstWhereOrNull(
            (localEvent) => localEvent.firestoreId == event.firestoreId,
      );

      if (existingEvent == null) {
        // Insert new event into SQLite
        await Event.insertEvent(event.toMap());
      } else {
        // Update existing event in SQLite
        await Event.updateEvent(existingEvent.id!, event.toMap());
      }
    }

    // Fetch updated local events
    final updatedLocalEvents = await Event.fetchEventsForUser(userId);

    return updatedLocalEvents;
  }

  static Future<Event> fetchEventById(String? eventId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('Events', where: 'firestore_id = ?', whereArgs: [eventId]);

    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    } else {
      throw Exception('Event not found.');
    }
  }

  static Future<int> deleteEvent(int id, {String? firestoreId}) async {
    final db = await _databaseHelper.database;

    // Step 1: Delete associated gifts from Firestore
    if (firestoreId != null) {
      try {
        final giftsQuerySnapshot = await FirebaseFirestore.instance
            .collection('gifts')
            .where('event_id', isEqualTo: firestoreId)
            .get();

        for (var doc in giftsQuerySnapshot.docs) {
          await FirebaseFirestore.instance.collection('gifts').doc(doc.id).delete();
        }

        // Step 2: Delete the event from Firestore
        await FirebaseFirestore.instance.collection('events').doc(firestoreId).delete();
      } catch (e) {
        print('Failed to delete associated gifts or event from Firestore: $e');
      }
    }

    // // Step 3: Delete associated gifts from SQLite
    // await db.delete(
    //   'Gifts',
    //   where: 'event_id = ?',
    //   whereArgs: [firestoreId],
    // );

    // Step 4: Delete the event from SQLite
    final rowsDeleted = await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );

    return rowsDeleted;
  }


//remove reqular fetch IMPPPPPPPPPPPPPPPP!!!!!!!!!!!1

}
