import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';
import 'db_helper.dart';
import 'cashier_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DBHelper();
  await dbHelper.createDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => AdminDashboard(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
