import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/events_model.dart';
import 'package:hedieaty_app/controllers/event_controller.dart';
import 'package:hedieaty_app/controllers/Session_controller.dart';
import 'package:hedieaty_app/views/LoginPage.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:hedieaty_app/views/MyEventDetails.dart';

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
    if (userId != null) {
      final allEvents = await _eventController.fetchEvents(userId);
      setState(() {
        events = allEvents;
        _sortEvents();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _addEvent(Event event, {int? published}) async {
    await _eventController.addEvent(event,published: published);
    _loadEvents();
  }

  void _updateEvent(Event event) async {
    await _eventController.updateEvent(event);
    _loadEvents();
  }

  void _deleteEvent(int id,{String? firestoreId}) async {
    if(firestoreId!=null){
      print(firestoreId);
      await _eventController.deleteEvent(id, firestoreId: firestoreId);

    }else{
      await _eventController.deleteEvent(id);
    }
    _loadEvents();
  }

  // String _getEventStatus(Event event) {
  //   final now = DateTime.now();
  //   if (event.date.isAfter(now)) {
  //     return 'Upcoming';
  //   } else if (event.date.isBefore(now)) {
  //     return 'Past';
  //   } else {
  //     return 'Current';
  //   }
  // }
  String _getEventStatus(Event event) {
    final now = DateTime.now();

    // Extract only the date parts (year, month, day) for comparison
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);

    if (eventDate.isAfter(today)) {
      return 'Upcoming';
    } else if (eventDate.isBefore(today)) {
      return 'Past';
    } else {
      return 'Current'; // Event date matches today's date
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
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: event?.name ?? '');
    final categoryController = TextEditingController(text: event?.category ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final dateController = TextEditingController(
        text: event != null ? event.date.toIso8601String().split('T')[0] : '');
    bool isPublished = event?.published ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event == null ? 'Add Event' : 'Edit Event'),
              content: SingleChildScrollView(
                child:
                Form(
                  key: _formKey,
                  child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Event Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the event name.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the event category.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the event location.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the event date.';
                        }
                        // Check if the date is in the correct format
                        try {
                          DateTime.parse(value);
                        } catch (e) {
                          return 'Please enter a valid date in YYYY-MM-DD format.';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      title: Text('Publish Event'),
                      value: isPublished,
                      onChanged: (value) {
                        setState(() {
                          isPublished = value;
                        });
                      },
                    ),
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

            final updatedEvent = Event(
            id: event?.id,
            name: nameController.text,
            category: categoryController.text,
            location: locationController.text,
            description: descriptionController.text,
            date: DateTime.parse(dateController.text),
            userId: await SecureSessionManager.getUserId() ?? 'unknown_user',
            published: isPublished,
            firestoreId: event?.firestoreId,
            );

            if (updatedEvent.id == null) {
            _addEvent(updatedEvent, published: updatedEvent.published?1:0);
            } else {
            _updateEvent(updatedEvent);
            }

            Navigator.pop(context);
            }
                  },
                ),
              ],
            );
          },
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
      IconButton(
      icon: Icon(Icons.refresh),
      tooltip: 'Refresh',
      onPressed: () {
        // Call the method to refresh events
        _loadEvents();
      },
      ),
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
          ? Center(child: Text("No events to show"))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final status = _getEventStatus(events[index]);
          return GestureDetector(
            onTap: () {
              // Navigate to EventDetailsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsPage(event: events[index]),
                ),
              );
            },
            child: Card(
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
                            '${events[index].published ? 'Live' : 'Offline'}',
                            style: TextStyle(
                              color: events[index].published ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: $status', // Display the status
                            style: TextStyle(
                              color: status == 'Upcoming'
                                  ? Colors.blue
                                  : status == 'Current'
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                              'Category: ${events[index].category}'
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${events[index].date.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.cloud_upload, color: Colors.blue),
                          onPressed: () async {
                            try {
                              await _eventController.publishEventToFirestore(events[index]);
                              setState(() {
                                events[index].published = true; // Update local state
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Event published successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to publish event: $e')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEventDialog(event: events[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteEvent(events[index].id!,firestoreId: events[index].firestoreId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
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
