import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入保姆端的侧边栏

class NanniesInfoScreen extends StatelessWidget {
  final String? userId;
  final String? userEmail;
  final String? userType;

  NanniesInfoScreen({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = userId != null && userEmail != null && userType != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nannies Information'),
      ),
      drawer: isLoggedIn
          ? NanniesSideMenu(
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
              );
            },
          ),
        ),
      ],
    );
  }
}
