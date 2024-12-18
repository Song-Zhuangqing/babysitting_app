import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart'; // 导入侧边栏文件
import 'parents_update_info.dart'; // 导入更新信息页面
import '../main_menu.dart'; // 导入主菜单页面

class ParentsPersonInfoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsPersonInfoScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsPersonInfoScreenState createState() =>
      _ParentsPersonInfoScreenState();
}

class _ParentsPersonInfoScreenState extends State<ParentsPersonInfoScreen> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // 获取父母的个人信息
  Future<void> _fetchUserInfo() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_parents_info.php'), // API 地址
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            userInfo = result['data']; // 假设后端返回的数据在 'data' 字段中
          });
        } else {
          // 处理错误
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch data: ${result['message']}')));
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(
              userId: widget.userId,
              userEmail: widget.userEmail,
              userType: widget.userType,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Personal Information'),
        ),
        drawer: SideMenu(
          userId: widget.userId,
          userEmail: widget.userEmail,
          userType: widget.userType,
        ),
        body: userInfo == null
            ? Center(child: CircularProgressIndicator()) // 加载指示器
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Name: ${userInfo!['parents_name']}', // 显示姓名
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Phone: ${userInfo!['parents_phone']}', // 显示手机号
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sex: ${userInfo!['parents_sex']}', // 显示性别
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Email: ${userInfo!['parents_email']}', // 显示邮箱
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Address: ${userInfo!['parents_address']}', // 显示地址
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    // 添加一个跳转到更新页面的按钮
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentsUpdateInfoScreen(
                              userId: widget.userId,
                              userEmail: widget.userEmail,
                              userType: widget.userType,
                              userInfo: userInfo!, // 传递当前用户信息
                            ),
                          ),
                        );
                      },
                      child: Text('Update Information'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
