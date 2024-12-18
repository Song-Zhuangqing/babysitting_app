import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:babysitting_app/screens/login_screen.dart';
import 'package:babysitting_app/screens/main_menu.dart';
import 'package:babysitting_app/screens/register_parent.dart';
import 'package:babysitting_app/screens/register_nanny.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen Integration Tests', () {
    testWidgets('LoginScreen displays all elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证页面元素
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email 和 Password 输入框
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget); // 登录按钮
      expect(find.widgetWithText(ElevatedButton, 'Register as Parent'), findsOneWidget); // 父母注册按钮
      expect(find.widgetWithText(ElevatedButton, 'Register as Nanny'), findsOneWidget); // 保姆注册按钮
    });

    testWidgets('Login fails with invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 输入无效的电子邮件格式
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid_email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

      // 点击登录按钮
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // 验证电子邮件格式错误提示
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Login fails with empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 直接点击登录按钮，不输入任何内容
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // 验证错误提示
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Login succeeds for registered Parent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 输入已注册的父母信息
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'janedoe@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'securePassword');

      // 点击登录按钮
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // 验证是否跳转到 MainMenuScreen 并显示父母界面
      expect(find.byType(MainMenuScreen), findsOneWidget);
      print('Passed: Login succeeded for registered Parent');
    });

    testWidgets('Login succeeds for registered Nanny', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 输入已注册的保姆信息
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'johndoe@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

      // 点击登录按钮
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // 验证是否跳转到 MainMenuScreen 并显示保姆界面
      expect(find.byType(MainMenuScreen), findsOneWidget);
      print('Passed: Login succeeded for registered Nanny');
    });

    testWidgets('Navigates to RegisterParentScreen when Register as Parent is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 点击 "Register as Parent" 按钮
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register as Parent'));
      await tester.pumpAndSettle();

      // 验证是否跳转到 RegisterParentScreen
      expect(find.byType(RegisterParentScreen), findsOneWidget);
    });

    testWidgets('Navigates to RegisterNannyScreen when Register as Nanny is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 点击 "Register as Nanny" 按钮
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register as Nanny'));
      await tester.pumpAndSettle();

      // 验证是否跳转到 RegisterNannyScreen
      expect(find.byType(RegisterNannyScreen), findsOneWidget);
    });

    testWidgets('Navigates back to MainMenuScreen on back press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 模拟按下返回按钮
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 验证是否返回到 MainMenuScreen
      expect(find.byType(MainMenuScreen), findsOneWidget);
    });
  });
}
