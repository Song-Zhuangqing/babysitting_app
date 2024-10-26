import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // 导入 image_picker 插件
import 'dart:convert';
import 'dart:io';
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
  bool nanniesCertificate = false; // 是否有证书
  File? certificateImage; // 存储选择的图片
  String password = '';

  final ImagePicker _picker = ImagePicker(); // 初始化 ImagePicker

  // 选择图片
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        certificateImage = File(pickedFile.path);
      });
    }
  }

  // 注册函数
  Future<void> _register() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/babysitting_app/php/register_nanny.php'), // 服务器的API地址
      );

      // 添加普通字段
      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      request.fields['email'] = email;
      request.fields['address'] = address;
      request.fields['password'] = password;
      request.fields['nannies_certificate'] = nanniesCertificate ? '1' : '0';

      // 如果有证书图片，添加文件字段
      if (certificateImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'certificate_image_url', // 与后端一致的字段名
          certificateImage!.path,
        ));
      }

      // 调试日志 - 打印要发送的数据
      print("Request fields: ${request.fields}");
      print("Request files: ${request.files}");

      final response = await request.send();
      final result = await response.stream.bytesToString(); // 解析响应

      // 调试日志 - 打印响应
      print("Response status: ${response.statusCode}");
      print("Response body: $result");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(result); // 解析 JSON 响应

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Registration successful')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // 跳转到登录页面
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Registration failed: ${jsonResponse['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server error')));
      }
    } catch (e) {
      // 捕获并显示网络错误
      print('Network error: $e');
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
          child: SingleChildScrollView( // 增加滚动视图，避免溢出
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
                  decoration: InputDecoration(labelText: 'Phone Number'),
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
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  onSaved: (value) => address = value ?? '',
                ),
                SwitchListTile(
                  title: Text('Do you have a certificate?'),
                  value: nanniesCertificate,
                  onChanged: (value) {
                    setState(() {
                      nanniesCertificate = value;
                    });
                  },
                ),
                if (nanniesCertificate) // 只有在用户有证书的情况下才显示上传按钮
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Certificate'),
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
                      _register();
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
