import 'package:flutter/material.dart';
import 'screens/main_menu.dart';

import 'services/auth_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Babysitting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartupLoadingScreen(), // 设置启动页面为加载页面
    );
  }
}

// 启动加载页面
class StartupLoadingScreen extends StatefulWidget {
  @override
  _StartupLoadingScreenState createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<StartupLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    await Future.delayed(Duration(seconds: 3)); // 模拟加载延迟
    bool isLoggedIn = await AuthManager.checkLoginStatus();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen(
            userId: AuthManager.userId,
            userEmail: AuthManager.userEmail,
            userType: AuthManager.userType,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainMenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图像
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/startup_image.png'), // 确保图片路径正确
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 加载指示器和文本
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
