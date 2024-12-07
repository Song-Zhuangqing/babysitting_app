import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入 NanniesSideMenu
import 'nannies_details_add.dart';

class NanniesDetailScreen extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesDetailScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nannies Details'),
      ),
      drawer: NanniesSideMenu(
        userId: userId,
        userEmail: userEmail,
        userType: userType,
      ),
      body: NanniesDetailsList(userId: userId),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 跳转到添加信息页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesDetailsAddScreen(
                userId: userId,
                userEmail: userEmail,
                userType: userType,
              ),
            ),
          ).then((_) {
            // 回到当前页面并刷新数据
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NanniesDetailScreen(
                  userId: userId,
                  userEmail: userEmail,
                  userType: userType,
                ),
              ),
            );
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Add Details',
      ),
    );
  }
}

class NanniesDetailsList extends StatefulWidget {
  final String userId;

  NanniesDetailsList({required this.userId});

  @override
  _NanniesDetailsListState createState() => _NanniesDetailsListState();
}

class _NanniesDetailsListState extends State<NanniesDetailsList> {
  List<Map<String, dynamic>> _details = [];
  String userName = ''; // 存储用户名
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 同时加载用户名和详细信息
  Future<void> _loadData() async {
    await Future.wait([
      _loadUserName(),
      _loadDetails(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nannies_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': widget.userId},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            userName = result['data']['nannies_name'] ?? 'Nanny';
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user name.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  // 加载详细信息
  Future<void> _loadDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nanny_details.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nannies_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _details = List<Map<String, dynamic>>.from(result['details']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load details: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _details.length,
            itemBuilder: (context, index) {
              final detail = _details[index];
              return Card(
                child: ListTile(
                  title: Text(userName), // 显示名字
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: RM ${detail['nannies_details_price']}'),
                      Text('Location: ${detail['nannies_details_location']}'),
                      Text('Date: ${detail['nannies_details_date']}'),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
