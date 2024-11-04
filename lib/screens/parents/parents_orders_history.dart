import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';
import 'parents_orders_details.dart';
import '../main_menu.dart';

class ParentsOrdersHistoryScreen extends StatefulWidget {
  final String userId;
  final String userEmail;

  ParentsOrdersHistoryScreen({
    required this.userId,
    required this.userEmail,
  });

  @override
  _ParentsOrdersHistoryScreenState createState() =>
      _ParentsOrdersHistoryScreenState();
}

class _ParentsOrdersHistoryScreenState
    extends State<ParentsOrdersHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_parents_orders.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'parents_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(result['orders']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load orders: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 返回到已登录状态的主菜单页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(
              userId: widget.userId,
              userEmail: widget.userEmail,
              userType: 'Parent',
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
        ),
        drawer: SideMenu(
          userId: widget.userId,
          userEmail: widget.userEmail,
          userType: 'Parent',
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
                    builder: (context) => ParentsOrdersDetailsScreen(
                      order: order,
                      orderId: order['orders_id'] ?? '', 
                      userEmail: widget.userEmail, 
                    ),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  title: Text('Order Date: ${order['orders_date'] ?? ''}'),
                  subtitle: Text('Nanny: ${order['nannies_name'] ?? ''}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
