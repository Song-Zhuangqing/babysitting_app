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
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_all_parents_child.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _needsDetails = List<Map<String, dynamic>>.from(result['details']);
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

  void _onSearchChanged() {
    setState(() {
      _filteredDetails = _needsDetails
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
              return Card(
                child: ListTile(
                  title: Text('Child Name: ${detail['parents_child_name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sex: ${detail['parents_child_sex'] ?? 'N/A'}'),
                      Text('Details: ${detail['parents_child_details']}'),
                      // 若需要额外字段，可以在此处添加显示逻辑
                    ],
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
