import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import '../side_menu.dart';


class ParentsChatListScreen extends StatelessWidget {
  final String userId;
  final String userEmail;

  ParentsChatListScreen({
    required this.userId,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Chats'),
      ),
      drawer: SideMenu(
        userId: userId,
        userEmail: userEmail,
        userType: 'parent',
      ),
      body: ChatList(userId: userId),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger refresh
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ParentsChatListScreen(
                userId: userId,
                userEmail: userEmail,
              ),
            ),
          );
        },
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        heroTag: 'refreshParentChatList',
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
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_parent_conversations.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'parents_id': widget.userId},
    );

    print('HTTP status: ${response.statusCode}');
    print('Response body: ${response.body}');

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
