import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../chat.dart';
import 'nannies_sidemenu.dart';

class NanniesChildDetailsScreen extends StatelessWidget {
  final String childName;
  final String childDetails;
  final String childId;
  final String childAddress;
  final String childAge;
  final String childLanguage;
  final String childRequire;
  final String childTime;
  final String childMoney;
  final String nanniesId;
  final String userEmail;
  final String userType;

  NanniesChildDetailsScreen({
    required this.childName,
    required this.childDetails,
    required this.childId,
    required this.childAddress,
    required this.childAge,
    required this.childLanguage,
    required this.childRequire,
    required this.childTime,
    required this.childMoney,
    required this.nanniesId,
    required this.userEmail,
    required this.userType,
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
                userEmail: userEmail,
                userType: userType,
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
        userEmail: userEmail,
        userType: userType,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: $childName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Details: $childDetails', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Address: $childAddress', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Age: $childAge', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Language: $childLanguage', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Requirements: $childRequire', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Time: $childTime', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Price: RM $childMoney', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => _startConversation(context),
              icon: Icon(Icons.message, color: Colors.white),
              label: Text('Start Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
              label: Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
