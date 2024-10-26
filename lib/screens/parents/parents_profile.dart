import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart'; // 父母端侧边栏
import 'parents_view_details.dart'; // 导入保姆详细信息页面
import '../login_screen.dart'; // 导入登录界面
import '../main_menu.dart'; // 导入主菜单

class ParentsProfileScreen extends StatelessWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  ParentsProfileScreen({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = userId != null && userEmail != null && userType != null;

    return WillPopScope(
      onWillPop: () async {
        if (!isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenuScreen(
                userId: userId,
                userEmail: userEmail,
                userType: userType,
              ),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nannies Information'),
        ),
        drawer: isLoggedIn
            ? SideMenu(
                userId: userId!,
                userEmail: userEmail!,
                userType: userType!,
              )
            : null,
        body: NanniesDetailsList(
          userId: userId,
          userEmail: userEmail,
          userType: userType,
        ),
      ),
    );
  }
}

class NanniesDetailsList extends StatefulWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  NanniesDetailsList({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  _NanniesDetailsListState createState() => _NanniesDetailsListState();
}

class _NanniesDetailsListState extends State<NanniesDetailsList> {
  List<Map<String, dynamic>> _nannyDetails = [];
  List<Map<String, dynamic>> _filteredDetails = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNannyDetails();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadNannyDetails() async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/babysitting_app/php/get_all_nanny_details.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        setState(() {
          _nannyDetails = List<Map<String, dynamic>>.from(result['details']);
          _filteredDetails = _nannyDetails;
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
      _filteredDetails = _nannyDetails
          .where((detail) =>
              detail['nannies_name']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              detail['nannies_details_content']
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

  void _navigateToDetailScreen(Map<String, dynamic> detail) {
    if (widget.userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParentsViewDetailsScreen(
            nanniesName: detail['nannies_name'],
            nanniesEmail: detail['nannies_email'],
            nanniesDetailsDate: detail['nannies_details_date'],
            nanniesDetailsPrice: detail['nannies_details_price'].toString(),
            nanniesDetailsContent: detail['nannies_details_content'],
            nanniesDetailsLocation: detail['nannies_details_location'],
            userId: detail['user_id'].toString(),
            parentsId: widget.userId!,
            parentsName: widget.userEmail!,
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
              Navigator.pop(context);
            },
            child: Text('Cancel'),
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
                onTap: () => _navigateToDetailScreen(detail),
                child: Card(
                  child: ListTile(
                    title: Text('Name: ${detail['nannies_name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${detail['nannies_details_price']}'),
                        Text('Content: ${detail['nannies_details_content']}'),
                        Text('Location: ${detail['nannies_details_location']}'),
                        Text('Date: ${detail['nannies_details_date']}'),
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
