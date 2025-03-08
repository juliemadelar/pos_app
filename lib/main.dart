import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
<<<<<<< HEAD
  databaseFactory =
      databaseFactoryFfi; // Ensure this is called before using openDatabase
=======
  databaseFactory = databaseFactoryFfi; // Ensure this is called before using openDatabase
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
  final dbHelper = DBHelper();
  await dbHelper.createDatabase();
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
      },
      builder: (context, child) {
        return child != null
            ? Navigator(
<<<<<<< HEAD
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => child,
                    settings: RouteSettings(
                      arguments: {'removeBackButton': true},
                    ),
                  ),
            )
=======
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => child,
                  settings: RouteSettings(arguments: {'removeBackButton': true}),
                ),
              )
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
            : Container();
      },
    );
  }
}
