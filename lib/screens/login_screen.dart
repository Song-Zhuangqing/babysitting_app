import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // 导入配置文件
import 'main_menu.dart'; // 导入主菜单页面
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
        Uri.parse('${Config.apiUrl}/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
          'password': password,
        },
      );

      print('HTTP status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          String userId = result['user_id'];
          String userType = result['user_type'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully Logged In')));

          // 跳转至 MainMenuScreen，并传递用户信息
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenuScreen(
                userId: userId,
                userEmail: email,
                userType: userType,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Internet Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 当用户按下返回按钮时，跳转到未登录状态的 MainMenuScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(), // 不传递用户信息以保持未登录状态
          ),
        );
        return false; // 阻止默认的返回行为
      },
      child: Scaffold(
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
                      print('Form saved, calling _login...');
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
      ),
    );
  }
}
