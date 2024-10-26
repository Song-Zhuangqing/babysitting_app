import 'package:flutter/material.dart';
import '../side_menu.dart';
import 'parents_review.dart';

class ParentsOrdersDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String userEmail;

  ParentsOrdersDetailsScreen({
    required this.order,
    required String orderId,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    // Debugging: Print order details to check if they are correct
    print("Order Details: $order");

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      drawer: SideMenu(
        userId: order['parents_id'] ?? '', // Ensure parents_id is passed correctly
        userEmail: userEmail, // 使用传递过来的用户邮箱
        userType: 'Parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Order Date: ${order['orders_date'] ?? 'No Date Available'}'),
            SizedBox(height: 10),
            Text('Nanny: ${order['nannies_name'] ?? 'No Nanny Name Available'}'),
            SizedBox(height: 10),
            Text('Location: ${order['orders_location'] ?? 'No Location Available'}'),
            SizedBox(height: 10),
            Text('Child Name: ${order['orders_child_name'] ?? 'No Child Name Available'}'),
            SizedBox(height: 10),
            Text('Price: ${order['nannies_details_price'] ?? 'No Price Available'}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Debugging: Print values passed to ParentsReviewScreen
          print("Review Screen Parameters: Order ID: ${order['orders_id']}, Parent ID: ${order['parents_id']}, Nanny ID: ${order['nannies_id']}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParentsReviewScreen(
                orderId: order['orders_id'] ?? '', // Ensure non-null value is passed
                parentsId: order['parents_id'] ?? '', // Ensure non-null value is passed
                nanniesId: order['nannies_id'] ?? '', // Ensure non-null value is passed
                userEmail: userEmail, // Correctly pass userEmail to the review screen
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
