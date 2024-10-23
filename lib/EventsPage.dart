import 'package:flutter/material.dart';
import 'event_model.dart';
import 'package:hedieaty_app/EventFormPage.dart';  // Assuming the form page is in a separate file

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    Event(name: 'Birthday Party', category: 'Personal', status: 'Upcoming', date: DateTime.now().add(Duration(days: 5))),
    Event(name: 'Conference', category: 'Work', status: 'Current', date: DateTime.now()),
    Event(name: 'Anniversary', category: 'Personal', status: 'Past', date: DateTime.now().subtract(Duration(days: 20))),
  ];

  String _sortBy = 'Name';

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
            items: <String>['Name', 'Category', 'Status']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by $value'),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index].name),
            subtitle: Text('Category: ${events[index].category}, Status: ${events[index].status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editEvent(index);  // Edit event
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      events.removeAt(index);  // Delete event
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,  // Add new event
        child: Icon(Icons.add),
      ),
    );
  }

  void _sortEvents() {
    setState(() {
      if (_sortBy == 'Name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'Category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortBy == 'Status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  // Adding new event
  void _addNewEvent() async {
    Event? newEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage()),
    );
    if (newEvent != null) {
      setState(() {
        events.add(newEvent);
      });
    }
  }

  // Editing existing event
  void _editEvent(int index) async {
    Event? updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormPage(event: events[index]),  // Pass the event for editing
      ),
    );
    if (updatedEvent != null) {
      setState(() {
        events[index] = updatedEvent;  // Update the event in the list
      });
    }
  }
}
