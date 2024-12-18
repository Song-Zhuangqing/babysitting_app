import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入配置文件

class NanniesUpdateInfoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;
  final Map<String, dynamic> userInfo;

  NanniesUpdateInfoScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
    required this.userInfo,
  });

  @override
  _NanniesUpdateInfoScreenState createState() =>
      _NanniesUpdateInfoScreenState();
}

class _NanniesUpdateInfoScreenState extends State<NanniesUpdateInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String phone;
  late String sex;
  late String email;
  late String address;

  @override
  void initState() {
    super.initState();
    // 初始化字段为用户当前信息
    name = widget.userInfo['nannies_name'];
    phone = widget.userInfo['nannies_phone'].toString();
    sex = widget.userInfo['nannies_sex'];
    email = widget.userInfo['nannies_email'];
    address = widget.userInfo['nannies_address'];
  }

  Future<void> _updateUserInfo() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/update_nannies_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
          'nannies_name': name,
          'nannies_phone': phone,
          'nannies_sex': sex,
          'nannies_email': email,
          'nannies_address': address,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Information updated successfully')));
          Navigator.pop(context); // 返回上一页
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Update failed: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Information'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) => phone = value!,
              ),
              DropdownButtonFormField<String>(
                value: sex,
                decoration: InputDecoration(labelText: 'Sex'),
                onChanged: (String? newValue) {
                  setState(() {
                    sex = newValue!;
                  });
                },
                items: <String>['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => address = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    _updateUserInfo(); // 更新用户信息
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
