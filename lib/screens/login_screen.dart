import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // 导入配置文件
import 'parents/parents_profile.dart'; // 导入父母个人主页
import 'nannies/nannies_profile.dart'; // 导入保姆个人主页
import 'register_parent.dart'; // 父母注册页面
import 'register_nanny.dart'; // 保姆注册页面

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/login.php'), // 使用配置文件中的 apiUrl
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
          'password': password,
        },
      );

      print('HTTP status: ${response.statusCode}'); // 打印HTTP状态码
      print('Response body: ${response.body}'); // 打印响应内容

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          String userId = result['user_id'];
          String userType = result['user_type'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully Logged In')));
          if (userType == 'parent') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ParentsProfileScreen(
                  userId: userId,
                  userEmail: email,
                  userType: userType,
                ),
              ), // 跳转到父母个人主页并传递 user_id
            );
          } else if (userType == 'nanny') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NanniesProfileScreen(
                  userId: userId,
                  userEmail: email,
                  userType: userType,
                ),
              ), // 跳转到保姆个人主页并传递 user_id
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      print('Error: $e'); // 打印错误信息
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Internet Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
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
                onSaved: (value) => email = value ?? '',
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
                    print('Form saved, calling _login...'); // 调试信息
                    _login();
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              // 父母注册按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterParentScreen()),
                  );
                },
                child: Text('Register as Parent'),
              ),
              SizedBox(height: 10),
              // 保姆注册按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterNannyScreen()),
                  );
                },
                child: Text('Register as Nanny'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
