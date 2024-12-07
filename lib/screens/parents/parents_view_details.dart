import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import '../side_menu.dart';
import 'parents_order.dart';
import 'parents_view_info.dart';

class ParentsViewDetailsScreen extends StatelessWidget {
  final String nanniesName;
  final String nanniesEmail;
  final String nanniesDetailsDate;
  final String nanniesDetailsPrice;
  final String nanniesDetailsContent;
  final String nanniesDetailsLocation;
  final String nanniesServiceTime;
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
    required this.nanniesServiceTime,
    required this.userId,
    required this.parentsId,
    required this.parentsName,
  });

  Future<void> _startConversation(BuildContext context) async {
    try {
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
                userEmail: parentsName,
                conversationId: result['conversation_id'].toString(),
                senderType: 'parent',
                userType: 'parent',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to start conversation: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  Future<void> _confirmSendRequest(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Request'),
        content: Text('Are you sure you want to send a request to $nanniesName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Send'),
          ),
        ],
      ),
    );
    if (confirm == true) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      drawer: SideMenu(
        userId: parentsId,
        userEmail: parentsName,
        userType: 'parent',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: $nanniesName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: $nanniesEmail', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: $nanniesDetailsDate', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Price: RM $nanniesDetailsPrice / hour', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Content: $nanniesDetailsContent', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: $nanniesDetailsLocation', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Service Time: $nanniesServiceTime', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Center(
              child: FloatingActionButton.extended(
                heroTag: 'viewInfoButton',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentsViewInfoScreen(
                        nannyId: userId,
                        userId: parentsId,
                        userEmail: parentsName,
                        userType: 'parent',
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.info),
                label: Text('View Nanny Info'),
              ),
            ),
            SizedBox(height: 20), // 增加与浮动按钮的间距
          ],
        ),
      ),
      floatingActionButton: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'chatButton',
            onPressed: () => _startConversation(context),
            icon: Icon(Icons.chat),
            label: Text('Chat'),
          ),
          FloatingActionButton.extended(
            heroTag: 'orderButton',
            onPressed: () => _confirmSendRequest(context),
            icon: Icon(Icons.done_outlined),
            label: Text('Send Request'),
          ),
          FloatingActionButton.extended(
            heroTag: 'backButton',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            label: Text('Back'),
          ),
        ],
      ),
    );
  }
}
