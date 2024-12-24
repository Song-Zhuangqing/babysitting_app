import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // 导入配置文件
import 'login_screen.dart'; // 导入登录界面

class RegisterNannyScreen extends StatefulWidget {
  @override
  _RegisterNannyScreenState createState() => _RegisterNannyScreenState();
}

class _RegisterNannyScreenState extends State<RegisterNannyScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String gender = '';
  String email = '';
  String address = '';
  String password = '';

  // 注册函数
  Future<void> _register() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/register_nanny.php'),
        body: {
          'name': name,
          'phone': phone,
          'gender': gender,
          'email': email,
          'address': address,
          'password': password,
        },
      );

      final result = json.decode(response.body);

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${result['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nanny Registration')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    helperText: 'e.g., John Doe',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                  onSaved: (value) => name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    helperText: 'e.g., 01112345678',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  onChanged: (_) => _formKey.currentState?.validate(),
                  onSaved: (value) => phone = value!,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Gender'),
                  value: gender.isEmpty ? null : gender,
                  onChanged: (value) => setState(() => gender = value!),
                  items: ['Select', 'Male', 'Female', 'Other']
                      .map((value) => DropdownMenuItem(
                            value: value == 'Select' ? '' : value,
                            child: Text(value),
                          ))
                      .toList(),
                  validator: (value) =>
                      value!.isEmpty ? 'Please select your gender' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    helperText: 'e.g., example@gmail.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (_) => _formKey.currentState?.validate(),
                  onSaved: (value) => email = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                    helperText: 'e.g., 123 Main Street',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                  onSaved: (value) => address = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: 'Choose a secure password',
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                  onSaved: (value) => password = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _register();
                    }
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 20),
                Text(
                  'You can upload your certificates later in the profile section.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
