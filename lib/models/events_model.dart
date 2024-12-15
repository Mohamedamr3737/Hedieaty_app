import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';


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
    if(published==1){
      publishEventToFirestore(fromMap(event));
      return 1;
    }else{
      final db = await _databaseHelper.database;
      return await db.insert('Events', event);
    }
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

  static Future<int> deleteEvent(int id, {String? firestoreId}) async {
    final db = await _databaseHelper.database;

    // Delete from SQLite
    final rowsDeleted = await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Delete from Firestore if `firestoreId` is provided
    if (firestoreId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(firestoreId)
            .delete();
      } catch (e) {
        print('Failed to delete event from Firestore: $e');
      }
    }

    return rowsDeleted;
  }


  static Future<void> publishEventToFirestore(Event event) async {
    try {
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

        // Save the Firestore document ID in the local database
        event.firestoreId = docRef.id;
        await updateEvent(event.id!, event.toMap());
      }
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
//remove reqular fetch IMPPPPPPPPPPPPPPPP!!!!!!!!!!!1

}
