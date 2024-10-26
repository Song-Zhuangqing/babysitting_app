import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import 'nannies_sidemenu.dart';

class NanniesChatListScreen extends StatelessWidget {
  final String userId;
  final String userEmail;

  NanniesChatListScreen({
    required this.userId,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nanny Chats'),
      ),
      drawer: NanniesSideMenu(
        userId: userId,
        userEmail: userEmail,
        userType: 'nanny',
      ),
      body: ChatList(userId: userId),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 触发刷新操作
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesChatListScreen(
                userId: userId,
                userEmail: userEmail,
              ),
            ),
          );
        },
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        heroTag: 'refreshNannyChatList',
      ),
    );
  }
}

class ChatList extends StatefulWidget {
  final String userId;

  ChatList({required this.userId});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
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
      body: {'nannies_id': widget.userId},
    );

    print('HTTP status: ${response.statusCode}'); // 打印HTTP状态码
    print('Response body: ${response.body}'); // 打印响应内容

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(result['conversations']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load conversations: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userId: widget.userId,
                  conversationId: conversation['conversation_id'].toString(),
                  senderType: 'nanny',
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Conversation with ${conversation['parent_name']}'),
              subtitle: Text('Last message: ${conversation['last_message']}'),
            ),
          ),
        );
      },
    );
  }
}
