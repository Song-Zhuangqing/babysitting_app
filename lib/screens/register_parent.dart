import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // 导入配置文件
import 'login_screen.dart'; // 导入登录界面

class RegisterParentScreen extends StatefulWidget {
  @override
  _RegisterParentScreenState createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String gender = ''; // 初始值为空
  String email = '';
  String address = ''; // 地址
  String password = '';

  Future<void> _register() async {
    print('Register method called'); // 调试信息
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/register_parent.php'), // 使用配置文件中的 apiUrl
        body: {
          'name': name,
          'phone': phone,
          'gender': gender,
          'email': email,
          'address': address,
          'password': password,
        },
      );

      print('HTTP status: ${response.statusCode}'); // 打印HTTP状态码
      print('Response body: ${response.body}'); // 打印响应内容

      if (response.statusCode == 200) {
        final result = response.body;
        if (result.trim() == "New record created successfully") {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Successfully Registered')));
          print('Navigating to LoginScreen...'); // 调试信息
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // 注册成功后跳转到登录界面
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed Registered: $result')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      print('Error: $e'); // 打印错误信息
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Internet Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parents Register')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  helperText: 'e.g., 01112345678', // 提供示例
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) => phone = value ?? '',
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: gender.isEmpty ? null : gender,
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                items: <String>['Select', 'Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value == 'Select' ? '' : value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  helperText: 'e.g., example@gmail.com', // 提供示例
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => address = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    print('Form saved, calling _register...'); // 调试信息
                    _register();
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
