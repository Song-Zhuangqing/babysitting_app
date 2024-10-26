import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入 NanniesSideMenu 组件

class NanniesDetailsAddScreen extends StatefulWidget {
  final String userId;

  NanniesDetailsAddScreen({required this.userId});

  @override
  _NanniesDetailsAddScreenState createState() => _NanniesDetailsAddScreenState();
}

class _NanniesDetailsAddScreenState extends State<NanniesDetailsAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String price = '';
  String content = '';
  String location = '';

  Future<void> _addNannyDetail() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/add_nanny_detail.php'), // 使用配置文件中的 apiUrl
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
          'nannies_details_price': price,
          'nannies_details_content': content,
          'nannies_details_location': location,
        },
      );

      print('HTTP status: ${response.statusCode}'); // 打印HTTP状态码
      print('Response body: ${response.body}'); // 打印响应内容

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully Added')));
          Navigator.pop(context, true); // 回到详情页面，并传递一个标志以便重新加载数据
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Add: ${result['message']}')));
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
      appBar: AppBar(title: Text('Add Nanny Detail')),
      drawer: NanniesSideMenu(
        userId: widget.userId,
        userEmail: 'example@example.com', // 你需要替换为实际的用户邮箱
        userType: 'nanny',
      ), // 使用 NanniesSideMenu
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
                onSaved: (value) => price = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Content'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
                onSaved: (value) => content = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
                onSaved: (value) => location = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    print('Form saved, calling _addNannyDetail...'); // 调试信息
                    _addNannyDetail();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
