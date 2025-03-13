import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'admin_dashboard.dart';
import 'login_page.dart';
import 'db_helper.dart';
import 'package:pos_app/cashier_dashboard.dart'; // Import the CashierDashboard page

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

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => Object()), // Add a dummy provider
        // Add other providers here if needed
      ],
      child: MyApp(),
    ),
  );
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
        '/cashier_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return CashierDashboard(username: args['username']);
        }, // Define the route
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
