import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../login_screen.dart';
import '../main_menu.dart';
import 'nannies_sidemenu.dart';
import 'nannies_child_details.dart';

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
          List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(result['details']);

          for (var detail in details) {
            String parentName = await _getParentName(detail['parents_id'] ?? '0');
            print('Fetched Parent Name: $parentName'); // 调试输出
            detail['parents_name'] = parentName; // 添加父母名字字段
          }

          setState(() {
            _childDetails = details;
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

  Future<String> _getParentName(String parentId) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_parents_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': parentId},
      );

      print('Response from getParentName: ${response.body}'); // 调试输出

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          return result['data']['parents_name'] ?? 'Unknown Parent';
        } else {
          return 'Unknown Parent';
        }
      } else {
        return 'Unknown Parent';
      }
    } catch (e) {
      print('Error in getParentName: $e');
      return 'Unknown Parent';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _filteredDetails = _childDetails;
      });
    } else {
      setState(() {
        _filteredDetails = _childDetails
            .where((detail) =>
                detail['parents_name']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                detail['parents_child_language']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToDetailScreen(Map<String, dynamic> detail) async {
    final parentId = detail['parents_id'] ?? '0';
    print('Parent ID: $parentId'); // 调试输出
    if (widget.userId != null) {
      String parentName = await _getParentName(parentId);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NanniesChildDetailsScreen(
            childName: parentName,
            childDetails: detail['parents_child_details'] ?? 'Not Provided',
            childId: parentId,
            childAddress: detail['parents_child_address'] ?? 'Not Provided',
            childAge: detail['parents_child_age'] ?? 'Not Specified',
            childLanguage: detail['parents_child_language'] ?? 'Not Specified',
            childRequire: detail['parents_child_require'] ?? 'None',
            childTime: detail['parents_child_time'] ?? 'Not Set',
            childMoney: detail['parents_child_money'] ?? '0',
            nanniesId: widget.userId!,
            userEmail: widget.userEmail!,
            userType: widget.userType!,
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
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('Login Required'),
          ],
        ),
        content: Text('You must log in to access this feature.'),
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
              print('Detail in ListView: ${detail.toString()}'); // 调试输出
              return GestureDetector(
                onTap: () => _navigateToDetailScreen(detail),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        detail['parents_name'] ?? 'Unknown Parent', // 显示父母名字
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${detail['parents_child_address']}'),
                          Text('Language: ${detail['parents_child_language']}'),
                          Text('Price: RM ${detail['parents_child_money']}'),
                        ],
                      ),
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
