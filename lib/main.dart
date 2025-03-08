import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';
import 'db_helper.dart';
import 'package:pos_app/cashier_dashboard.dart'; // Import the CashierDashboard page
// Import the image_picker package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory =
      databaseFactoryFfi; // Ensure this is called before using openDatabase
  final dbHelper = DBHelper();
  await dbHelper.initializeDatabase(); // Ensure the database is initialized

  // Check if users table is empty and insert default users if necessary
  bool hasUsers = await dbHelper.hasUsers();
  if (!hasUsers) {
    await dbHelper.addUser('Julie', 'cashier', 'password123', 'cashier');
    await dbHelper.addUser('Admin', 'admin', 'password123', 'admin');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/': (context) => AdminDashboard(),
        '/login': (context) => LoginPage(),
        '/cashier_dashboard':
            (context) => CashierDashboard(), // Define the routehe route
      },
      builder: (context, child) {
        return child != null
            ? Navigator(
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => child,
                    settings: RouteSettings(
                      arguments: {'removeBackButton': true},
                    ),
                  ),
            )
            : Container();
      },
    );
  }
}
