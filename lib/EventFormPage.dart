import 'package:flutter/material.dart';
import 'event_model.dart';  // Assuming event model is defined in another file

class EventFormPage extends StatefulWidget {
  final Event? event;  // Nullable event

  EventFormPage({this.event});  // Constructor accepting a nullable event

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _status;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing event values if editing, otherwise default values
    if (widget.event != null) {
      _name = widget.event!.name;
      _category = widget.event!.category;
      _status = widget.event!.status;
      _selectedDate = widget.event!.date;
    } else {
      _name = '';
      _category = 'Personal';
      _status = 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (value) => _category = value!,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Upcoming', 'Current', 'Past'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newEvent = Event(
                      name: _name,
                      category: _category,
                      status: _status,
                      date: _selectedDate,
                    );
                    Navigator.pop(context, newEvent);  // Return the new/updated event
                  }
                },
                child: Text(widget.event == null ? 'Add Event' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
