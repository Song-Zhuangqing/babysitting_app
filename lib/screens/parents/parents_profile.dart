import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart'; // 父母端侧边栏
import 'parents_view_details.dart'; // 保姆详细信息页面
import '../login_screen.dart'; // 登录页面
import '../main_menu.dart'; // 主菜单页面

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
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
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

  void _navigateToDetailScreen(Map<String, dynamic> detail) {
    if (widget.userId != null) {
      print('Navigating with detail: $detail'); // 调试信息
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
            nanniesServiceTime: detail['nannies_service_time'] ?? 'Not Provided',
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
                onTap: () => _navigateToDetailScreen(detail),
                child: Card(
                  child: ListTile(
                    title: Text('Name: ${detail['nannies_name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: RM ${detail['nannies_details_price']} / hour'),
                        Text('Location: ${detail['nannies_details_location']}'),
                        Text('Service Time: ${detail['nannies_service_time'] ?? 'Not Provided'}'),
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
