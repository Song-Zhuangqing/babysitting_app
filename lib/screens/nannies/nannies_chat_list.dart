import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import 'nannies_sidemenu.dart';

class NanniesChatListScreen extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType; // 确保传递 userType

  NanniesChatListScreen({
    required this.userId,
    required this.userEmail,
    required this.userType, // 初始化 userType
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
        userType: userType, // 确保传递 userType
      ),
      body: ChatList(
        userId: userId,
        userEmail: userEmail, // 确保传递 userEmail
        userType: userType, // 确保传递 userType
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 触发刷新操作
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesChatListScreen(
                userId: userId,
                userEmail: userEmail,
                userType: userType, // 确保传递 userType
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
  final String userEmail; // 添加 userEmail 参数
  final String userType; // 添加 userType 参数

  ChatList({
    required this.userId,
    required this.userEmail, // 初始化 userEmail
    required this.userType, // 初始化 userType
  });

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
      Uri.parse('${Config.apiUrl}/get_nanny_conversations.php'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conversations: ${result['message']}')),
        );
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
                  userEmail: widget.userEmail, // 传递 userEmail
                  userType: widget.userType, // 传递 userType
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
