import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.init();
  await DbHelper.seed();
  runApp(const MyMkatabaApp());
}

class MyMkatabaApp extends StatelessWidget {
  const MyMkatabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Mkataba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C3FC5),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
      ),
      home: const LoginPage(),
    );
  }
}
