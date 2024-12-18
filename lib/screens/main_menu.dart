import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入 SystemNavigator
import 'nannies/nannies_sidemenu.dart';
import 'parents/parents_info.dart';
import 'parents/parents_profile.dart';
import 'nannies/nannies_profile.dart';
import 'side_menu.dart';
import 'login_screen.dart';
import 'register_parent.dart';
import 'register_nanny.dart';
import 'nannies/nannies_info.dart'; // 导入 nannies_info 页面

class MainMenuScreen extends StatelessWidget {
  final String? userId; // 用户ID可为空
  final String? userEmail;
  final String? userType;

  MainMenuScreen({
    this.userId,
    this.userEmail,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = userId != null && userEmail != null && userType != null;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // 切换应用到后台
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        drawer: isLoggedIn
            ? (userType == 'parent'
                ? SideMenu(
                    userId: userId!,
                    userEmail: userEmail!,
                    userType: userType!,
                  )
                : NanniesSideMenu(
                    userId: userId!,
                    userEmail: userEmail!,
                    userType: userType!,
                  ))
            : null, // 未登录则不显示侧边栏
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 添加图片
              Image.asset(
                'assets/images/main_menu.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                key: Key('mainMenuImage'), // 添加 Key
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  // 查看保姆信息按钮
                  _buildNavigationButton(
                    context,
                    title: 'View Nannies Information',
                    key: Key('viewNanniesButton'),
                    targetScreen: userType == 'nanny'
                        ? NanniesInfoScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          )
                        : ParentsProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                  ),
                  SizedBox(height: 10),
                  // 查看父母需求按钮
                  _buildNavigationButton(
                    context,
                    title: 'View Parents Needs',
                    key: Key('viewParentsButton'),
                    targetScreen: userType == 'parent'
                        ? ParentsInfoScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          )
                        : NanniesProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (!isLoggedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 登录按钮
                    Expanded(
                      child: _buildNavigationButton(
                        context,
                        title: 'Login',
                        key: Key('loginButton'),
                        targetScreen: LoginScreen(),
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                    SizedBox(width: 10),
                    // 注册按钮
                    Expanded(
                      child: ElevatedButton(
                        key: Key('registerButton'), // 添加 Key
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () => _showRegisterDialog(context),
                        child: Text('Register'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 抽取的按钮构建方法
  Widget _buildNavigationButton(
    BuildContext context, {
    required String title,
    required Widget targetScreen,
    required Key key,
    Color backgroundColor = Colors.blue,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        child: Text(title),
      ),
    );
  }

  // 显示注册选项的弹窗
  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Register as:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                key: Key('registerParentButton'), // 添加 Key
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterParentScreen()),
                  );
                },
                child: Text('Parent'),
              ),
              ElevatedButton(
                key: Key('registerNannyButton'), // 添加 Key
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterNannyScreen()),
                  );
                },
                child: Text('Nanny'),
              ),
            ],
          ),
        );
      },
    );
  }
}
