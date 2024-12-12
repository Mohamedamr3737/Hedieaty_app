import 'package:hedieaty_app/models/events_model.dart';

class EventController {
  Future<List<Event>> fetchAllEvents(String? userId) async {
    return await Event.fetchEventsForUser(userId);
  }

  Future<int> addEvent(Event event) async {
    return await Event.insertEvent(event.toMap());
  }

  Future<int> updateEvent(Event event) async {
    return await Event.updateEvent(event.id!, event.toMap());
  }

  Future<int> deleteEvent(int id) async {
    return await Event.deleteEvent(id);
  }
}
