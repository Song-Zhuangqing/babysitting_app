import 'package:babysitting_app/screens/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:babysitting_app/screens/main_menu.dart';
import 'package:babysitting_app/screens/login_screen.dart';
import 'package:babysitting_app/screens/parents/parents_profile.dart';
import 'package:babysitting_app/screens/parents/parents_child.dart';
import 'package:babysitting_app/screens/parents/parents_orders_history.dart';
import 'package:babysitting_app/screens/parents/parents_chat.dart';
import 'package:babysitting_app/screens/parents/parents_personal_info.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SideMenu Integration Tests', () {
    late String userId;
    late String userEmail;
    late String userType;

    setUp(() {
      userId = 'testUserId';
      userEmail = 'test@example.com';
      userType = 'parent';
    });

    testWidgets('SideMenu displays all menu options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();

      // 验证菜单项
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Personal File'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Navigates to Home (MainMenuScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Home"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // 验证导航到 MainMenuScreen
      expect(find.byType(MainMenuScreen), findsOneWidget);
    });

    testWidgets('Navigates to Information (ParentsProfileScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Information"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Information'));
      await tester.pumpAndSettle();

      // 验证导航到 ParentsProfileScreen
      expect(find.byType(ParentsProfileScreen), findsOneWidget);
    });

    testWidgets('Navigates to Personal File (ParentsPersonInfoScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Personal File"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal File'));
      await tester.pumpAndSettle();

      // 验证导航到 ParentsPersonInfoScreen
      expect(find.byType(ParentsPersonInfoScreen), findsOneWidget);
    });

    testWidgets('Navigates to Publish (ParentsChildScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Publish"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      // 验证导航到 ParentsChildScreen
      expect(find.byType(ParentsChildScreen), findsOneWidget);
    });

    testWidgets('Navigates to Chat (ParentsChatScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Chat"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // 验证导航到 ParentsChatScreen
      expect(find.byType(ParentsChatScreen), findsOneWidget);
    });

    testWidgets('Navigates to History (ParentsOrdersHistoryScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "History"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // 验证导航到 ParentsOrdersHistoryScreen
      expect(find.byType(ParentsOrdersHistoryScreen), findsOneWidget);
    });

    testWidgets('Navigates to LoginScreen on Logout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: SideMenu(userId: userId, userEmail: userEmail, userType: userType),
          ),
        ),
      );

      // 打开 Drawer 并点击 "Logout"
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // 验证导航到 LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
