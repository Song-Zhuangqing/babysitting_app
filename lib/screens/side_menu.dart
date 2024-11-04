import 'package:flutter/material.dart';
import '../screens/parents/parents_profile.dart';
import '../screens/parents/parents_child.dart';
import '../screens/parents/parents_orders_history.dart';
import '../screens/parents/parents_chat.dart';
import '../screens/login_screen.dart';
import '../screens/main_menu.dart'; // 导入新的主页文件
import 'parents/parents_personal_info.dart'; // 导入个人信息页面

class SideMenu extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userType;

  SideMenu({
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainMenuScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Information'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentsProfileScreen(
                    userId: userId,
                    userEmail: userEmail,
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Personal File'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentsPersonInfoScreen(
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
                  builder: (context) => ParentsChildScreen(
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
                  builder: (context) => ParentsChatScreen(
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
            title: Text('History'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentsOrdersHistoryScreen(
                    userId: userId, 
                    userEmail: userEmail,
                  ),
                ),
              );
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
