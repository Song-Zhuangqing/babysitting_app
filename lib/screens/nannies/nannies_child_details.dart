import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import 'nannies_sidemenu.dart'; // 使用保姆端的侧边栏

class NanniesChildDetailsScreen extends StatelessWidget {
  final String childName;
  final String childDetails;
  final String childId;
  final String nanniesId;
  final String userEmail; // 添加 userEmail
  final String userType;  // 添加 userType

  NanniesChildDetailsScreen({
    required this.childName,
    required this.childDetails,
    required this.childId,
    required this.nanniesId,
    required this.userEmail, // 初始化 userEmail
    required this.userType,  // 初始化 userType
  });

  Future<void> _startConversation(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/create_conversation.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'parents_id': childId,
          'nannies_id': nanniesId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: nanniesId,
                userEmail: userEmail, // 传递 userEmail
                userType: userType,   // 传递 userType
                conversationId: result['conversation_id'].toString(),
                senderType: 'nanny',
              ),
            ),
          );
        } else {
          _showSnackBar(context, 'Failed to start conversation: ${result['message']}');
        }
      } else {
        _showSnackBar(context, 'Server Error');
      }
    } catch (e) {
      _showSnackBar(context, 'Network Error: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Details'),
      ),
      drawer: NanniesSideMenu(
        userId: nanniesId,
        userEmail: userEmail, // 使用传递过来的 userEmail
        userType: userType,   // 使用传递过来的 userType
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: $childName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Details: $childDetails', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'messageButton',
            onPressed: () => _startConversation(context),
            child: Icon(Icons.message),
            tooltip: 'Send Message',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'backButton',
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
