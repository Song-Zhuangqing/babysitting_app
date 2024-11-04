import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入SystemNavigator
import 'nannies/nannies_sidemenu.dart';
import 'parents/parents_profile.dart'; // 父母端的相关文件
import 'nannies/nannies_profile.dart'; // 保姆端的相关文件
import 'side_menu.dart'; // 父母端侧边栏
import 'login_screen.dart'; // 导入登录页面
import 'register_parent.dart'; // 父母注册页面
import 'register_nanny.dart'; // 保姆注册页面

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
        // 切换应用到后台
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        drawer: isLoggedIn
            ? _getSideMenuForUserType(context) // 登录后根据用户类型显示侧边栏
            : null, // 未登录则不显示侧边栏
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 查看保姆信息按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (userType == 'parent') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NanniesProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                        ),
                        ModalRoute.withName('/main_menu'),
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParentsProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                        ),
                        ModalRoute.withName('/main_menu'),
                      );
                    }
                  },
                  child: Text('View Nannies Information'),
                ),
              ),
              SizedBox(height: 20),
              // 查看父母需求按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (userType == 'parent') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParentsProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                        ),
                        ModalRoute.withName('/main_menu'),
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NanniesProfileScreen(
                            userId: userId,
                            userEmail: userEmail,
                            userType: userType,
                          ),
                        ),
                        ModalRoute.withName('/main_menu'),
                      );
                    }
                  },
                  child: Text('View Parents Needs'),
                ),
              ),
              SizedBox(height: 20),
              // 如果未登录，则显示 Login 和 Register 按钮
              if (!isLoggedIn) ...[
                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ),
                SizedBox(height: 10),
                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      _showRegisterDialog(context);
                    },
                    child: Text('Register'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 显示注册选项的弹窗，选择作为父母或保姆进行注册
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterParentScreen()),
                  );
                },
                child: Text('Parent'),
              ),
              ElevatedButton(
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

  // 根据用户类型显示相应的侧边栏
  Widget? _getSideMenuForUserType(BuildContext context) {
    if (userType == 'parent') {
      return SideMenu(
        userId: userId!,
        userEmail: userEmail!,
        userType: userType!,
      );
    } else if (userType == 'nanny') {
      return NanniesSideMenu(
        userId: userId!,
        userEmail: userEmail!,
        userType: userType!,
      );
    }
    return null;
  }
}
