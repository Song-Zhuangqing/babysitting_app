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
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNannyDetails();
    _loadNannyReviews();
    _loadCertificates();
  }

  // 获取保姆的详细信息
  Future<void> _loadNannyDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_info.php'),
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
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load nanny details: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Network Error: $e'); // 打印错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 获取保姆的评价信息
  Future<void> _loadNannyReviews() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_review.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nannies_id': widget.nannyId, // 传递保姆ID
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            reviews = List<Map<String, dynamic>>.from(result['data']); // 获取评价信息
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load reviews: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Network Error: $e'); // 打印错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    }
  }

  // 获取证书信息
  Future<void> _loadCertificates() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_certificates.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.nannyId, // 传递保姆ID
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            certificates = List<Map<String, dynamic>>.from(result['certificates']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load certificates: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Network Error: $e');
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
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 显示保姆的基本信息
                  if (nannyDetails != null) ...[
                    Text('Nanny Name: ${nannyDetails!['nannies_name']}'),
                    SizedBox(height: 10),
                    Text('Phone: ${nannyDetails!['nannies_phone']}'),
                    SizedBox(height: 10),
                    Text('Sex: ${nannyDetails!['nannies_sex']}'),
                    SizedBox(height: 10),
                    Text('Email: ${nannyDetails!['nannies_email']}'),
                    SizedBox(height: 10),
                    Text('Address: ${nannyDetails!['nannies_address']}'),
                    SizedBox(height: 20),
                  ],
                  // 显示证书信息
                  Text(
                    'Certificates:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (certificates.isNotEmpty)
                    ...certificates.map((certificate) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Certificate Info: ${certificate['certificate_info']}'),
                          SizedBox(height: 5),
                          if (certificate['certificate_image_url'] != null)
                            Image.network(
                              certificate['certificate_image_url'],
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Text('Failed to load image');
                              },
                            ),
                          Divider(),
                        ],
                      );
                    }).toList()
                  else
                    Text('No certificates available.'),
                  SizedBox(height: 20),
                  // 显示保姆的评价内容和星级
                  Text(
                    'Reviews:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (reviews.isNotEmpty)
                    ...reviews.map((review) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Review Content: ${review['reviews_content']}'),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (review['reviews_star'] ?? 0) ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        ))
                  else
                    Text('No reviews available.'),
                ],
              ),
            ),
    );
  }
}
