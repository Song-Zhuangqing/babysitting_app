import 'package:flutter/material.dart';
import 'nannies_sidemenu.dart'; // 使用保姆端的侧边栏
import '../chat.dart'; // 导入聊天界面
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class NanniesChildDetailsScreen extends StatelessWidget {
  final String childName;
  final String childDetails;
  final String childId;
  final String nanniesId;

  NanniesChildDetailsScreen({
    required this.childName,
    required this.childDetails,
    required this.childId,
    required this.nanniesId,
  });

  Future<void> _startConversation(BuildContext context) async {
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
              conversationId: result['conversation_id'].toString(),
              senderType: 'nanny',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start conversation: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Details'),
      ),
      drawer: NanniesSideMenu(
        userId: nanniesId,
        userEmail: 'example@example.com', // 替换为实际的保姆用户邮箱
        userType: 'nanny',
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
            onPressed: () => _startConversation(context),
            child: Icon(Icons.message),
            tooltip: 'Send Message',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesChildDetailsScreen(
                    childName: childName,
                    childDetails: childDetails,
                    childId: childId,
                    nanniesId: nanniesId,
                  ),
                ),
              );
            },
            child: Icon(Icons.refresh),
            tooltip: 'Refresh',
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
