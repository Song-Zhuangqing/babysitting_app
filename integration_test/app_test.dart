import 'package:babysitting_app/screens/login_screen.dart';
import 'package:babysitting_app/screens/main_menu.dart';
import 'package:babysitting_app/screens/register_parent.dart';
import 'package:babysitting_app/screens/register_nanny.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:babysitting_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Babysitting App Tests (Without Login)', () {
    testWidgets('Startup loading screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // 验证加载页面
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 3));

      // 验证跳转到 MainMenuScreen
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('Login button navigates to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle(Duration(seconds: 3));

      // 点击登录按钮
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pumpAndSettle();

      // 验证跳转到 LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Register button shows register options', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle(Duration(seconds: 3));

      // 点击注册按钮
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pumpAndSettle();

      // 验证弹窗是否显示
      expect(find.text('Register as:'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Nanny'), findsOneWidget);

      // 点击 Parent 注册按钮
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();

      // 验证跳转到 RegisterParentScreen
      expect(find.byType(RegisterParentScreen), findsOneWidget);
    });

    testWidgets('Register Parent screen displays and submits successfully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterParentScreen()));

      // 验证页面标题
      expect(find.text('Parents Register'), findsOneWidget);

      // 填写表单字段
      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe'); // Name
      await tester.enterText(find.byType(TextFormField).at(1), '0123456789'); // Phone

      // 点击并选择 Gender 下拉选项
      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      expect(dropdownFinder, findsOneWidget); // 验证 DropdownButtonFormField 存在
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle(); // 等待下拉菜单完全展开
      await tester.tap(find.text('Female').last); // 选择 Female
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(2), 'janedoe@example.com'); // Email
      await tester.enterText(find.byType(TextFormField).at(3), '456 Park Avenue'); // Address
      await tester.enterText(find.byType(TextFormField).at(4), 'securePassword'); // Password

      // 点击提交按钮
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 验证是否跳转到 LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      print('Passed: Parent registration form submitted successfully');
    });

    testWidgets('Register Nanny screen displays and submits successfully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterNannyScreen()));

      // 验证页面标题
      expect(find.text('Nanny Registration'), findsOneWidget);

      // 填写表单字段
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe'); // Name
      await tester.enterText(find.byType(TextFormField).at(1), '01112345678'); // Phone

      // 点击并选择 Gender 下拉选项
      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      expect(dropdownFinder, findsOneWidget); // 验证 DropdownButtonFormField 存在
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle(); // 等待下拉菜单完全展开
      await tester.tap(find.text('Male').last); // 选择 Male
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(2), 'johndoe@example.com'); // Email
      await tester.enterText(find.byType(TextFormField).at(3), '123 Main Street'); // Address
      await tester.enterText(find.byType(TextFormField).at(4), 'password123'); // Password

      // 点击提交按钮
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 验证是否跳转到 LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      print('Passed: Nanny registration form submitted successfully');
    });

    testWidgets('Skipping tests for NanniesInfoScreen and ParentsInfoScreen', (WidgetTester tester) async {
      // 此测试直接验证逻辑跳过
      print('Skipping tests for NanniesInfoScreen and ParentsInfoScreen as they require login.');
    });
  });
}
