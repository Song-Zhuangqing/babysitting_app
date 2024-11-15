import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入配置文件
import 'nannies_sidemenu.dart'; // 导入保姆端侧边栏文件
import 'nannies_update_info.dart'; // 导入修改信息页面
import 'nannies_update_certificate.dart'; // 导入修改证书页面

class NanniesPersonalInfoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesPersonalInfoScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _NanniesPersonalInfoScreenState createState() =>
      _NanniesPersonalInfoScreenState();
}

class _NanniesPersonalInfoScreenState extends State<NanniesPersonalInfoScreen> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // 获取保姆的个人信息
  Future<void> _fetchUserInfo() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nannies_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            userInfo = result['data'];
            // 打印图片路径进行调试
            print('Image URL: ${userInfo!['certificate_image_url']}');
          });
        } else {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      drawer: NanniesSideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Name: ${userInfo!['nannies_name']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Phone: ${userInfo!['nannies_phone']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sex: ${userInfo!['nannies_sex']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Email: ${userInfo!['nannies_email']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Address: ${userInfo!['nannies_address']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Certificate: ${userInfo!['nannies_certificate'] == 1 ? 'Yes' : 'No'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    if (userInfo!['nannies_certificate'] == 1 &&
                        userInfo!['certificate_image_url'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.network(
                          userInfo!['certificate_image_url'],
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Failed to load image');
                          },
                        ),
                      ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (userInfo != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NanniesUpdateInfoScreen(
                                  userId: widget.userId,
                                  userEmail: widget.userEmail,
                                  userType: widget.userType,
                                  userInfo: userInfo!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Edit Information'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NanniesUpdateCertificateScreen(
                                userId: widget.userId,
                                userEmail: widget.userEmail,
                                userType: widget.userType,
                              ),
                            ),
                          );
                        },
                        child: Text('Update Certificate'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchUserInfo();
        },
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    );
  }
}
