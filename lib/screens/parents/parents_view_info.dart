import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入API配置文件
import '../side_menu.dart'; // 导入侧边栏

class ParentsViewInfoScreen extends StatefulWidget {
  final String nannyId; // 保姆的ID
  final String userId; // 父母的ID
  final String userEmail; // 父母的Email
  final String userType; // 用户类型

  ParentsViewInfoScreen({
    required this.nannyId,
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsViewInfoScreenState createState() => _ParentsViewInfoScreenState();
}

class _ParentsViewInfoScreenState extends State<ParentsViewInfoScreen> {
  Map<String, dynamic>? nannyDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNannyDetails();
  }

  // 从API获取保姆信息
  Future<void> _loadNannyDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_info.php'), // 使用 get_info.php
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nannies_id': widget.nannyId, // 传递保姆ID
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            nannyDetails = result['data']; // 获取保姆信息
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load nanny details: ${result['message']}')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Network Error: $e'); // 打印错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nanny Information'),
      ),
      drawer: SideMenu(
        userId: widget.userId, // 使用传递的父母ID
        userEmail: widget.userEmail, // 使用传递的父母Email
        userType: widget.userType, // 使用传递的用户类型
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 加载中状态
          : nannyDetails != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Nanny Name: ${nannyDetails!['nannies_name']}'),
                      SizedBox(height: 10),
                      Text('Phone: ${nannyDetails!['nannies_phone']}'),
                      SizedBox(height: 10),
                      Text('Sex: ${nannyDetails!['nannies_sex']}'),
                      SizedBox(height: 10),
                      Text('Email: ${nannyDetails!['nannies_email']}'),
                      SizedBox(height: 10),
                      Text('Address: ${nannyDetails!['nannies_address']}'),
                      SizedBox(height: 10),
                      Text('Certificate: ${nannyDetails!['nannies_certificate'] == '1' ? 'Yes' : 'No'}'),
                      SizedBox(height: 10),
                      nannyDetails!['certificate_image_url'] != null
                          ? Image.network('${Config.apiUrl}/uploads/${nannyDetails!['certificate_image_url']}')
                          : Text('No certificate uploaded'),
                    ],
                  ),
                )
              : Center(child: Text('Failed to load nanny details')),
    );
  }
}
