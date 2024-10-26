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
      ), // 使用 NanniesSideMenu
      body: NanniesDetailsList(userId: userId),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesDetailsAddScreen(userId: userId),
                ),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
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
            },
            child: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nanny_details.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nannies_id': widget.userId,
      },
    );

    print('HTTP status: ${response.statusCode}'); // 打印HTTP状态码
    print('Response body: ${response.body}'); // 打印响应内容

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
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _details.length,
      itemBuilder: (context, index) {
        final detail = _details[index];
        return Card(
          child: ListTile(
            title: Text('Price: ${detail['nannies_details_price']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Content: ${detail['nannies_details_content']}'),
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
