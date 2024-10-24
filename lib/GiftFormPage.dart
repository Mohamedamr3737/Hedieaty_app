import 'package:flutter/material.dart';
import 'gift_model.dart';  // Assuming gift model is defined in a separate file

class GiftFormPage extends StatefulWidget {
  final Gift? gift;  // Existing gift if editing

  GiftFormPage({this.gift});

  @override
  _GiftFormPageState createState() => _GiftFormPageState();
}

class _GiftFormPageState extends State<GiftFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _status;

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      _name = widget.gift!.name;
      _category = widget.gift!.category;
      _status = widget.gift!.status;
    } else {
      _name = '';
      _category = 'Accessories';
      _status = 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter gift name';
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
                items: ['Available', 'Pledged', 'Delivered'].map((String value) {
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
                    final newGift = Gift(
                      name: _name,
                      category: _category,
                      status: _status,
                      isPledged: _status == 'Pledged',
                    );
                    Navigator.pop(context, newGift);  // Return new/edited gift
                  }
                },
                child: Text(widget.gift == null ? 'Add Gift' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
