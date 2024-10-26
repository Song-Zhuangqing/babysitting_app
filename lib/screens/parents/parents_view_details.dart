import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import '../side_menu.dart';
import 'parents_order.dart';
import 'parents_view_info.dart'; // 导入保姆个人信息页面

class ParentsViewDetailsScreen extends StatelessWidget {
  final String nanniesName;
  final String nanniesEmail;
  final String nanniesDetailsDate;
  final String nanniesDetailsPrice;
  final String nanniesDetailsContent;
  final String nanniesDetailsLocation;
  final String userId;
  final String parentsId;
  final String parentsName;

  ParentsViewDetailsScreen({
    required this.nanniesName,
    required this.nanniesEmail,
    required this.nanniesDetailsDate,
    required this.nanniesDetailsPrice,
    required this.nanniesDetailsContent,
    required this.nanniesDetailsLocation,
    required this.userId,
    required this.parentsId,
    required this.parentsName,
  });

  Future<void> _startConversation(BuildContext context) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/create_conversation.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'parents_id': parentsId,
        'nannies_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: parentsId,
              conversationId: result['conversation_id'].toString(),
              senderType: 'parent',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start conversation: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // 点击后跳转至保姆个人信息页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentsViewInfoScreen(
                    nannyId: userId, 
                    userId: parentsId, 
                    userEmail: parentsName, 
                    userType: 'parents', // 需要修改变量名
                  ),
                ),
              );
            },
            tooltip: 'View Nanny Info',
          ),
        ],
      ),
      drawer: SideMenu(
        userId: parentsId,
        userEmail: parentsName,
        userType: 'Parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: $nanniesName'),
            SizedBox(height: 10),
            Text('Email: $nanniesEmail'),
            SizedBox(height: 10),
            Text('Date: $nanniesDetailsDate'),
            SizedBox(height: 10),
            Text('Price: $nanniesDetailsPrice'),
            SizedBox(height: 10),
            Text('Content: $nanniesDetailsContent'),
            SizedBox(height: 10),
            Text('Location: $nanniesDetailsLocation'),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _startConversation(context),
            child: Icon(Icons.chat),
            tooltip: 'Start Chat',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentsOrderScreen(
                    nanniesName: nanniesName,
                    nanniesDetailsPrice: nanniesDetailsPrice,
                    parentsName: parentsName,
                    parentsId: parentsId,
                    nanniesId: userId,
                  ),
                ),
              );
            },
            child: Icon(Icons.shopping_cart),
            tooltip: 'Place Order',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
            tooltip: 'Back to List',
          ),
        ],
      ),
    );
  }
}
