import '../database/database_helper.dart';

class Event {
  int? id;
  String name;
  DateTime date;
  String? location;
  String? description;
  String? category;
  bool published;
  int userId;

  Event({
    this.id,
    required this.name,
    required this.date,
    this.location,
    this.description,
    this.category,
    this.published = false,
    required this.userId,
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
    );
  }

  // Database operations through the model
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await _databaseHelper.database;
    return await db.insert('Events', event);
  }

  static Future<List<Event>> fetchEventsForUser(String? userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('Events', where: 'id = ?', whereArgs: [userId]);
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  static Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await _databaseHelper.database;
    return await db.update('Events', event, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteEvent(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('Events', where: 'id = ?', whereArgs: [id]);
  }
}
