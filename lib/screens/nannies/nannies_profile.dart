import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../login_screen.dart';
import '../main_menu.dart';
import 'nannies_sidemenu.dart'; // 导入侧边栏
import 'nannies_child_details.dart'; // 导入详细信息页面

class NanniesProfileScreen extends StatelessWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  NanniesProfileScreen({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = userId != null && userEmail != null && userType != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parents Needs'),
      ),
      drawer: isLoggedIn
          ? NanniesSideMenu(
              userId: userId!,
              userEmail: userEmail!,
              userType: userType!,
            )
          : null,
      body: ParentsChildList(
        userId: userId,
        userEmail: userEmail,
        userType: userType,
      ),
    );
  }
}

class ParentsChildList extends StatefulWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  ParentsChildList({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  _ParentsChildListState createState() => _ParentsChildListState();
}

class _ParentsChildListState extends State<ParentsChildList> {
  List<Map<String, dynamic>> _childDetails = [];
  List<Map<String, dynamic>> _filteredDetails = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChildDetails();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadChildDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_all_parents_child.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _childDetails = List<Map<String, dynamic>>.from(result['details']);
            _filteredDetails = _childDetails;
          });
        } else {
          _showSnackBar('Failed to load details: ${result['message']}');
        }
      } else {
        _showSnackBar('Server Error');
      }
    } catch (e) {
      _showSnackBar('Network Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDetails = _childDetails
          .where((detail) =>
              detail['parents_child_name']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              detail['parents_child_details']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetailScreen(String childName, String childDetails, String childId) {
    if (widget.userId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NanniesChildDetailsScreen(
            childName: childName,
            childDetails: childDetails,
            childId: childId,
            nanniesId: widget.userId!,
            userEmail: widget.userEmail!, // 添加 userEmail
            userType: widget.userType!,   // 添加 userType
          ),
        ),
      );
    } else {
      _showLoginPrompt();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You must log in to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainMenuScreen()),
              );
            },
            child: Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredDetails.length,
            itemBuilder: (context, index) {
              final detail = _filteredDetails[index];
              return GestureDetector(
                onTap: () => _navigateToDetailScreen(
                  detail['parents_child_name'],
                  detail['parents_child_details'],
                  detail['parents_id'],
                ),
                child: Card(
                  child: ListTile(
                    title: Text('Name: ${detail['parents_child_name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sex: ${detail['parents_child_sex']}'),
                        Text('Details: ${detail['parents_child_details']}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
