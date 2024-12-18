import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';
import 'parents_child_add.dart';
import '../main_menu.dart';

class ParentsChildScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsChildScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsChildScreenState createState() => _ParentsChildScreenState();
}

class _ParentsChildScreenState extends State<ParentsChildScreen> {
  List<Map<String, dynamic>> _childrenDetails = [];

  @override
  void initState() {
    super.initState();
    _loadChildrenDetails();
  }

  Future<void> _loadChildrenDetails() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/get_parents_children.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'parents_id': widget.userId},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _childrenDetails = List<Map<String, dynamic>>.from(result['details']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load details: ${result['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(
              userId: widget.userId,
              userEmail: widget.userEmail,
              userType: widget.userType,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Child Information'),
        ),
        drawer: SideMenu(
          userId: widget.userId,
          userEmail: widget.userEmail,
          userType: widget.userType,
        ),
        body: ListView.builder(
          itemCount: _childrenDetails.length,
          itemBuilder: (context, index) {
            final detail = _childrenDetails[index];
            return Card(
              child: ListTile(
                title: Text('Details: ${detail['parents_child_details']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${detail['parents_child_address']}'),
                    Text('Age: ${detail['parents_child_age']}'),
                    Text('Language: ${detail['parents_child_language']}'),
                    Text('Requirements: ${detail['parents_child_require']}'),
                    Text('Service Time: ${detail['parents_child_time']}'),
                    Text('Price: RM ${detail['parents_child_money']} / hour'),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParentsChildAddScreen(
                  userId: widget.userId,
                  userEmail: widget.userEmail,
                  userType: widget.userType,
                ),
              ),
            ).then((_) => _loadChildrenDetails()); // 刷新页面数据
          },
          child: Icon(Icons.add),
          tooltip: 'Add Child',
        ),
      ),
    );
  }
}
