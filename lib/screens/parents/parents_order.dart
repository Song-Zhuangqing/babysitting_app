import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';

import 'parents_profile.dart';

class ParentsOrderScreen extends StatefulWidget {
  final String nanniesName;
  final String nanniesDetailsPrice;
  final String parentsName;
  final String parentsId;
  final String nanniesId;

  ParentsOrderScreen({
    required this.nanniesName,
    required this.nanniesDetailsPrice,
    required this.parentsName,
    required this.parentsId,
    required this.nanniesId,
  });

  @override
  _ParentsOrderScreenState createState() => _ParentsOrderScreenState();
}

class _ParentsOrderScreenState extends State<ParentsOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String ordersLocation = '';
  String ordersChildName = '';

  Future<void> _placeOrder() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/place_order.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'parents_id': widget.parentsId,
        'parents_name': widget.parentsName,
        'nannies_id': widget.nanniesId,
        'nannies_name': widget.nanniesName,
        'orders_location': ordersLocation,
        'orders_child_name': ordersChildName,
        'nannies_details_price': widget.nanniesDetailsPrice,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParentsProfileScreen(
            userId: widget.parentsId,
            userEmail: widget.parentsName,
            userType: 'parent',
          )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Request'),
      ),
      drawer: SideMenu(
        userId: widget.parentsId,
        userEmail: widget.parentsName,
        userType: 'parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Nanny Name: ${widget.nanniesName}'),
              SizedBox(height: 10),
              Text('Price: ${widget.nanniesDetailsPrice}'),
              SizedBox(height: 10),
              Text('Parent Name: ${widget.parentsName}'),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => ordersLocation = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Child Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your child\'s name';
                  }
                  return null;
                },
                onSaved: (value) => ordersChildName = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    _placeOrder();
                  }
                },
                child: Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
