import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart'; // 导入父母端的侧边栏
import '../main_menu.dart'; // 导入主菜单界面

class ParentsInfoScreen extends StatelessWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  ParentsInfoScreen({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = userId != null && userEmail != null && userType != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parents Posted Needs'),
      ),
      drawer: isLoggedIn
          ? SideMenu(
              userId: userId!,
              userEmail: userEmail!,
              userType: userType!,
            )
          : null,
      body: ParentsNeedsList(
        userId: userId,
        userEmail: userEmail,
        userType: userType,
      ),
    );
  }
}

class ParentsNeedsList extends StatefulWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  ParentsNeedsList({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  _ParentsNeedsListState createState() => _ParentsNeedsListState();
}

class _ParentsNeedsListState extends State<ParentsNeedsList> {
  List<Map<String, dynamic>> _needsDetails = [];
  List<Map<String, dynamic>> _filteredDetails = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNeedsDetails();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadNeedsDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_all_parents_child.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(result['details']);
          for (var detail in details) {
            String parentName = await _getParentName(detail['parents_id'] ?? '0');
            detail['parents_name'] = parentName; // 添加父母名字字段
          }
          setState(() {
            _needsDetails = details;
            _filteredDetails = _needsDetails;
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    }
  }

  Future<String> _getParentName(String parentId) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/get_parents_info.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': parentId},
      );

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
      print('Error fetching parent name: $e');
      return 'Unknown Parent';
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _filteredDetails = _needsDetails;
      });
    } else {
      setState(() {
        _filteredDetails = _needsDetails
            .where((detail) =>
                (detail['parents_name'] ?? '')
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                (detail['parents_child_language'] ?? '')
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
                        detail['parents_name'] ?? 'Unknown Parent',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${detail['parents_child_address'] ?? 'Not Provided'}'),
                          Text('Language: ${detail['parents_child_language'] ?? 'Not Specified'}'),
                          Text('Price: RM ${detail['parents_child_money'] ?? '0'}'),
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
