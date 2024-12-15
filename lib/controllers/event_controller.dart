import 'package:hedieaty_app/models/events_model.dart';

class EventController {
  Future<List<Event>> fetchAllEvents(String? userId) async {
    return await Event.fetchEventsForUser(userId);
  }

  Future<int> addEvent(Event event , {int? published}) async {
    return await Event.insertEvent(event.toMap(),published: published);
  }

  Future<void> updateEvent(Event event) async {
    await Event.updateEvent(event.id!, event.toMap());

    if (event.published) {
      // Publish to Firestore
      await Event.publishEventToFirestore(event);
    } else {
      // Unpublish from Firestore
      await Event.unpublishEventFromFirestore(event.firestoreId);
    }
  }






  Future<int> deleteEvent(int id,{String? firestoreId}) async {
    return await Event.deleteEvent(id,firestoreId: firestoreId);
  }

  Future<void> publishEventToFirestore(Event event) async {
    return await Event.publishEventToFirestore(event);
  }

  Future<void> unpublishEventFromFirestore(String? firestoreId) async {
    return await Event.unpublishEventFromFirestore(firestoreId);
  }

  Future<List<Event>> fetchEvents(String? userId) async {
    return await Event.fetchEvents(userId);
  }

  }
