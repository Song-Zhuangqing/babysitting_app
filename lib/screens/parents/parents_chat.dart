import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import '../side_menu.dart'; // 导入父母端的侧边栏
import '../main_menu.dart'; // 导入主菜单页面

class ParentsChatScreen extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsChatScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(
              userId: userId,
              userEmail: userEmail,
              userType: userType,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Parents Chat'),
        ),
        drawer: SideMenu(
          userId: userId,
          userEmail: userEmail,
          userType: userType,
        ),
        body: ParentsChatList(
          userId: userId,
          userEmail: userEmail,
          userType: userType,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ParentsChatScreen(
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
      ),
    );
  }
}

class ParentsChatList extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsChatList({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsChatListState createState() => _ParentsChatListState();
}

class _ParentsChatListState extends State<ParentsChatList> {
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_parent_conversations.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'parents_id': widget.userId},
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
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
                  userType: widget.userType,    // 传递 userType
                  conversationId: conversation['conversation_id'].toString(),
                  senderType: 'parent',
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Conversation with ${conversation['nanny_name']}'),
              subtitle: Text('Last message: ${conversation['last_message']}'),
            ),
          ),
        );
      },
    );
  }
}
