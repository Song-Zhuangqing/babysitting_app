import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../main_menu.dart';
import 'nannies_details_add.dart';
import 'nannies_orders_history.dart';
import 'nannies_profile.dart';
import 'nannies_detail.dart'; // 导入 nannies_detail.dart
import 'nannies_chat.dart';
import 'nannies_personal_info.dart';

class NanniesSideMenu extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesSideMenu({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userType),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userType[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
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
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Information'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesProfileScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.file_present),
            title: Text('Personal File'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesPersonalInfoScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.publish),
            title: Text('Publish'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesDetailScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Chat'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesChatScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Service History'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NanniesOrdersHistoryScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
