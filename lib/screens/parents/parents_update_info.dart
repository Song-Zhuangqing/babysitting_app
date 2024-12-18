import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart'; // 导入侧边栏

class ParentsUpdateInfoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;
  final Map<String, dynamic> userInfo; // 包含用户信息

  ParentsUpdateInfoScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
    required this.userInfo,
  });

  @override
  _ParentsUpdateInfoScreenState createState() =>
      _ParentsUpdateInfoScreenState();
}

class _ParentsUpdateInfoScreenState extends State<ParentsUpdateInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String phone;
  late String sex;
  late String address;

  @override
  void initState() {
    super.initState();
    // 初始化字段为用户当前信息
    name = widget.userInfo['parents_name'];
    phone = widget.userInfo['parents_phone'].toString(); // 确保将 int 转为 String
    sex = widget.userInfo['parents_sex'];
    address = widget.userInfo['parents_address'];
  }

  // 更新用户信息
  Future<void> _updateUserInfo() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/update_parents_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
          'parents_name': name,
          'parents_phone': phone,
          'parents_sex': sex,
          'parents_address': address,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Information updated successfully')));
          Navigator.pop(context); // 返回上一页
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Update failed: ${result['message']}')));
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
