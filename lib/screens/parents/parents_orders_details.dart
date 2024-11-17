import 'package:flutter/material.dart';
import '../side_menu.dart';
import 'parents_review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ParentsOrdersDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String userEmail;

  ParentsOrdersDetailsScreen({
    required this.order,
    required this.userEmail,
  });

  @override
  _ParentsOrdersDetailsScreenState createState() => _ParentsOrdersDetailsScreenState();
}

class _ParentsOrdersDetailsScreenState extends State<ParentsOrdersDetailsScreen> {
  List<Map<String, dynamic>> reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final String? nanniesId = widget.order['nannies_id']; // 确保 nannies_id 存在

    print("Nannies ID: $nanniesId");

    if (nanniesId == null || nanniesId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_review.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'nannies_id': nanniesId},
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            reviews = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      drawer: SideMenu(
        userId: widget.order['parents_id'] ?? '',
        userEmail: widget.userEmail,
        userType: 'parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Order Date: ${widget.order['orders_date'] ?? 'No Date Available'}'),
                    SizedBox(height: 10),
                    Text('Nanny: ${widget.order['nannies_name'] ?? 'No Nanny Name Available'}'),
                    SizedBox(height: 10),
                    Text('Location: ${widget.order['orders_location'] ?? 'No Location Available'}'),
                    SizedBox(height: 10),
                    Text('Child Name: ${widget.order['orders_child_name'] ?? 'No Child Name Available'}'),
                    SizedBox(height: 10),
                    Text('Price: ${widget.order['nannies_details_price'] ?? 'No Price Available'}'),
                    SizedBox(height: 20),
                    Text('Reviews:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    if (reviews.isNotEmpty)
                      ...reviews.map((review) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Review: ${review['reviews_content']}'),
                                SizedBox(height: 5),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (review['reviews_star'] ?? 0) ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                    );
                                  }),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParentsReviewScreen(
                orderId: widget.order['orders_id'] ?? '',
                parentsId: widget.order['parents_id'] ?? '',
                nanniesId: widget.order['nannies_id'] ?? '',
                userEmail: widget.userEmail,
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
