import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入保姆端的侧边栏

class NanniesReviewScreen extends StatefulWidget {
  final String orderId;
  final String parentsId;
  final String nanniesId;

  NanniesReviewScreen({
    required this.orderId,
    required this.parentsId,
    required this.nanniesId,
  });

  @override
  _NanniesReviewScreenState createState() => _NanniesReviewScreenState();
}

class _NanniesReviewScreenState extends State<NanniesReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _submitReview() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/add_review.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nannies_id': widget.nanniesId,  // 保姆ID
        'orders_id': widget.orderId,     // 订单ID
        'parents_id': widget.parentsId,  // 家长ID
        'reviews_content': _reviewController.text,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review submitted successfully')));
        Navigator.pop(context); // 返回订单详情页
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit review: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Review'),
      ),
      drawer: NanniesSideMenu(
        userId: widget.nanniesId,
        userEmail: 'example@example.com', // 替换为实际用户邮箱
        userType: 'Nanny',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Write your review',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
