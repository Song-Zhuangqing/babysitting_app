import 'package:flutter/material.dart';
import 'nannies_review.dart';
import 'nannies_sidemenu.dart'; // 导入侧边栏

class NanniesOrdersDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String userEmail; // 新增：当前登录用户的邮箱

  NanniesOrdersDetailsScreen({
    required this.order,
    required this.userEmail, // 接收当前登录用户的邮箱
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      drawer: NanniesSideMenu(
        userId: order['nannies_id'] ?? '',
        userEmail: userEmail, // 使用传递的实际用户邮箱
        userType: 'Nanny',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Order Date: ${order['orders_date'] ?? ''}'),
            SizedBox(height: 10),
            Text('Nanny: ${order['nannies_name'] ?? ''}'),
            SizedBox(height: 10),
            Text('Parent: ${order['parents_name'] ?? ''}'),
            SizedBox(height: 10),
            Text('Location: ${order['orders_location'] ?? ''}'),
            SizedBox(height: 10),
            Text('Child Name: ${order['orders_child_name'] ?? ''}'),
            SizedBox(height: 10),
            Text('Price: ${order['nannies_details_price'] ?? ''}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesReviewScreen(
                orderId: order['orders_id'] ?? '',
                parentsId: order['parents_id'] ?? '',
                nanniesId: order['nannies_id'] ?? '',
              ),
            ),
          );
        },
        child: Icon(Icons.rate_review),
        tooltip: 'Review',
      ),
    );
  }
}
