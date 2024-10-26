// 修改后的 NanniesOrdersHistoryScreen.dart 文件
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_orders_details.dart';
import 'nannies_sidemenu.dart';

class NanniesOrdersHistoryScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesOrdersHistoryScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _NanniesOrdersHistoryScreenState createState() => _NanniesOrdersHistoryScreenState();
}

class _NanniesOrdersHistoryScreenState extends State<NanniesOrdersHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nannies_orders.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nannies_id': widget.userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(result['orders']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load orders: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      drawer: NanniesSideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,  // 确保在侧边栏中传递正确的用户邮箱
        userType: widget.userType,
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesOrdersDetailsScreen(
                    order: order,
                  ),
                ),
              );
            },
            child: Card(
              child: ListTile(
                title: Text('Order Date: ${order['orders_date'] ?? ''}'),
                subtitle: Text('Parent: ${order['parents_name'] ?? ''}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
