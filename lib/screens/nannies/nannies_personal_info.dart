import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入配置文件
import '../main_menu.dart';
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
  List<Map<String, dynamic>> certificates = []; // 存储证书信息

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchCertificates();
  }

  // 获取保姆的个人信息
  Future<void> _fetchUserInfo() async {
    try {
      print('Fetching user info for user ID: ${widget.userId}');
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nannies_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': widget.userId},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            userInfo = result['data'];
          });
        } else {
          print('Failed to fetch user info: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch data: ${result['message']}')));
        }
      } else {
        print('Server error while fetching user info.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e, stackTrace) {
      print('Network error while fetching user info: $e');
      print('Stack trace:\n$stackTrace');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  // 获取证书信息
  Future<void> _fetchCertificates() async {
    try {
      print('Fetching certificates for user ID: ${widget.userId}');
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_certificates.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': widget.userId},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            certificates = List<Map<String, dynamic>>.from(result['certificates']);
          });
        } else {
          print('Failed to fetch certificates: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch certificates: ${result['message']}')));
        }
      } else {
        print('Server error while fetching certificates.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e, stackTrace) {
      print('Network error while fetching certificates: $e');
      print('Stack trace:\n$stackTrace');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  Future<bool> _onWillPop() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                      SizedBox(height: 20),
                      Text(
                        'Certificates:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      if (certificates.isEmpty)
                        Text('No certificates available', style: TextStyle(fontSize: 16)),
                      ...certificates.map((certificate) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Info: ${certificate['certificate_info']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            if (certificate['certificate_image_url'] != null)
                              Image.network(
                                certificate['certificate_image_url'],
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Failed to load image: $error');
                                  return Text('Failed to load image');
                                },
                              ),
                            Divider(),
                          ],
                        );
                      }).toList(),
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
                          child: Text('Add Certificate'),
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
            _fetchCertificates();
          },
          child: Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ),
    );
  }
}
