import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'side_menu.dart'; // 导入side_menu.dart

class ChatScreen extends StatefulWidget {
  final String userId;
  final String conversationId;
  final String senderType;

  ChatScreen({required this.userId, required this.conversationId, required this.senderType});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_messages.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'conversation_id': widget.conversationId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(result['messages']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load messages: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  Future<void> _sendMessage() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/send_message.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'conversation_id': widget.conversationId,
        'sender_id': widget.userId,
        'sender_type': widget.senderType,
        'message_content': _messageController.text,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _messageController.clear();
        _loadMessages(); // 重新加载消息
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      drawer: SideMenu(
        userId: widget.userId,
        userEmail: 'example@example.com', // 替换为实际用户邮箱
        userType: widget.senderType,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['message_content']),
                  subtitle: Text('${message['sender_type']} - ${message['create_time']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
