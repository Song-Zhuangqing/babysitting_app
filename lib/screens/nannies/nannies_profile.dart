import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入侧边栏
import 'nannies_child_details.dart'; // 导入详细信息页面
import '../login_screen.dart'; // 导入登录界面
import '../main_menu.dart'; // 导入主菜单界面

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: ${result['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server Error')),
      );
    }
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NanniesChildDetailsScreen(
            childName: childName,
            childDetails: childDetails,
            childId: childId,
            nanniesId: widget.userId!,
          ),
        ),
      );
    } else {
      _showLoginPrompt(context);
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You must log in to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainMenuScreen()), // 返回到主菜单
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
