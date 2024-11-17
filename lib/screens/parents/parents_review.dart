import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 导入 RatingBar 插件
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';

class ParentsReviewScreen extends StatefulWidget {
  final String orderId;
  final String parentsId;
  final String nanniesId;
  final String userEmail; // 接收 userEmail

  ParentsReviewScreen({
    required this.orderId,
    required this.parentsId,
    required this.nanniesId,
    required this.userEmail, // 初始化 userEmail
  });

  @override
  _ParentsReviewScreenState createState() => _ParentsReviewScreenState();
}

class _ParentsReviewScreenState extends State<ParentsReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0; // 用于存储星星评级

  Future<void> _submitReview() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/add_review.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'parents_id': widget.parentsId,
        'orders_id': widget.orderId,
        'nannies_id': widget.nanniesId,
        'reviews_content': _reviewController.text,
        'reviews_star': _rating.toInt().toString(), // 提交星星个数
      },
    );

    print("Submitting review: ${_reviewController.text}");
    print("Star Rating: $_rating");
    print("Order ID: ${widget.orderId}, Parent ID: ${widget.parentsId}, Nanny ID: ${widget.nanniesId}");

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review submitted successfully')));
        Navigator.pop(context);
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
      drawer: SideMenu(
        userId: widget.parentsId,
        userEmail: widget.userEmail, // 传递邮箱给侧边栏
        userType: 'parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
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
