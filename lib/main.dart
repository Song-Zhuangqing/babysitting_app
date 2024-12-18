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
    if (!mounted) return; // 确保组件未被销毁
    bool isLoggedIn = await AuthManager.checkLoginStatus();
    if (!mounted) return; // 再次检查组件状态

    // 根据登录状态导航
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenuScreen(
          userId: isLoggedIn ? AuthManager.userId : null,
          userEmail: isLoggedIn ? AuthManager.userEmail : null,
          userType: isLoggedIn ? AuthManager.userType : null,
        ),
      ),
    );
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
                image: AssetImage('assets/images/startup_image.png'), // 确保图片路径正确
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 加载指示器和文本
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  key: Key('loadingIndicator'), // 添加 Key 用于测试
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  key: Key('loadingText'), // 添加 Key 用于测试
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
