import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';

class ParentsChildAddScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsChildAddScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsChildAddScreenState createState() => _ParentsChildAddScreenState();
}

class _ParentsChildAddScreenState extends State<ParentsChildAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String childName = '';
  String childSex = '';
  String childDetails = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';

  Future<void> _addChild() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/add_parents_child.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'parents_id': widget.userId,
        'parents_child_name': childName,
        'parents_child_sex': childSex,
        'parents_child_details': childDetails,
        'parents_child_address_line1': addressLine1,
        'parents_child_address_line2': addressLine2,
        'parents_child_city': city,
        'parents_child_state': state,
        'parents_child_postal_code': postalCode,
        'parents_child_country': country,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Child added successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add child: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child Information'),
      ),
      drawer: SideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Child Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s name';
                  }
                  return null;
                },
                onSaved: (value) => childName = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Child Sex'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s sex';
                  }
                  return null;
                },
                onSaved: (value) => childSex = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Child Details'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s details';
                  }
                  return null;
                },
                onSaved: (value) => childDetails = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address Line 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address line 1';
                  }
                  return null;
                },
                onSaved: (value) => addressLine1 = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address Line 2'),
                onSaved: (value) => addressLine2 = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
                onSaved: (value) => city = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                onSaved: (value) => state = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the postal code';
                  }
                  return null;
                },
                onSaved: (value) => postalCode = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the country';
                  }
                  return null;
                },
                onSaved: (value) => country = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    _addChild();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
