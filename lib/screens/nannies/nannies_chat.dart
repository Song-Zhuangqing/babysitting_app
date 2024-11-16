import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart';  // 导入 NanniesSideMenu
import '../chat.dart';

class NanniesChatScreen extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesChatScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nannies Chat'),
      ),
      drawer: NanniesSideMenu(
        userId: userId,
        userEmail: userEmail,
        userType: userType,
      ),  // 使用 NanniesSideMenu
      body: NanniesChatList(
        userId: userId,
        userEmail: userEmail,
        userType: userType,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 触发刷新操作
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesChatScreen(
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
    );
  }
}

class NanniesChatList extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesChatList({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _NanniesChatListState createState() => _NanniesChatListState();
}

class _NanniesChatListState extends State<NanniesChatList> {
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nanny_conversations.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nannies_id': widget.userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(result['conversations']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load conversations: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return Card(
          child: ListTile(
            title: Text('Parent: ${conversation['parent_name']}'),
            subtitle: Text('Last message: ${conversation['last_message']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userId: widget.userId,
                    userEmail: widget.userEmail, // 传递 userEmail
                    userType: widget.userType,   // 传递 userType
                    conversationId: conversation['conversation_id'].toString(),
                    senderType: 'nanny',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
