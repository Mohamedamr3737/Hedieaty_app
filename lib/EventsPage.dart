import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/user_model.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/controllers/event_controller.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
import 'package:hedieaty_app/LoginPage.dart';
class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _eventController = EventController();
  List<Event> events = [];
  String _sortBy = 'Status';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final String? userId = await SecureSessionManager.getUserId();
    print(":::::::::::::::::::::::::::::::::::::::::::::::::::00");
    print(userId);
    if (userId != null) {
      final fetchedEvents = await _eventController.fetchAllEvents(userId);
      setState(() {
        events = fetchedEvents;
        _sortEvents();
      });
    } else {
      // Redirect to login if no user ID found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }


  void _addEvent(Event event) async {
    await _eventController.addEvent(event);
    _loadEvents();
  }

  void _updateEvent(Event event) async {
    await _eventController.updateEvent(event);
    _loadEvents();
  }

  void _deleteEvent(int id) async {
    await _eventController.deleteEvent(id);
    _loadEvents();
  }

  String _getEventStatus(Event event) {
    final now = DateTime.now();
    if (event.date.isAfter(now)) {
      return 'Upcoming';
    } else if (event.date.isBefore(now)) {
      return 'Past';
    } else {
      return 'Current';
    }
  }

  void _sortEvents() {
    setState(() {
      if (_sortBy == 'Status') {
        events.sort((a, b) {
          final statusA = _getEventStatus(a);
          final statusB = _getEventStatus(b);
          return statusA.compareTo(statusB);
        });
      } else if (_sortBy == 'Name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  void _showEventDialog({Event? event}) {
    final nameController = TextEditingController(text: event?.name ?? '');
    final categoryController = TextEditingController(text: event?.category ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final dateController = TextEditingController(
        text: event != null ? event.date.toIso8601String().split('T')[0] : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  keyboardType: TextInputType.datetime,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final newEvent = Event(
                  id: event?.id,
                  name: nameController.text,
                  category: categoryController.text,
                  location: locationController.text,
                  description: descriptionController.text,
                  date: DateTime.parse(dateController.text),
                  userId: event?.userId ?? 1, // Replace with dynamic user ID
                  published: event?.published ?? false,
                );

                if (event == null) {
                  _addEvent(newEvent);
                } else {
                  _updateEvent(newEvent);
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            icon: Icon(Icons.sort),
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
                _sortEvents();
              });
            },
            items: <String>['Name', 'Status']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by $value'),
              );
            }).toList(),
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final status = _getEventStatus(events[index]);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          events[index].name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Category: ${events[index].category}, Status: $status',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Date: ${events[index].date.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Edit and Delete Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEventDialog(event: events[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteEvent(events[index].id!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
