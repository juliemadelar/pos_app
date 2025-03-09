import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'db_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _initializeDatabase();
  }

  void _updateDateTime() {
    setState(() {
      currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
  }

  void _initializeDatabase() async {
    await _dbHelper.initializeDatabase(); // Ensure the database is initialized
    bool hasUsers = await _dbHelper.hasUsers();
    bool hasProducts = await _dbHelper.hasProducts();

    if (!hasUsers || !hasProducts) {
      await _dbHelper.createAndSaveProductTables();
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database initialized with default data.')),
      );
    }
  }

  Future<void> addUser(
    String name,
    String username,
    String password,
    String role,
  ) async {
    Database db = await _dbHelper.database;
    await db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
      'name': name,
    });
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    var user = await _dbHelper.getUser(username, password);
    if (!mounted) return; // Check if the widget is still mounted
    if (user != null) {
      String loginTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
      await _dbHelper.insertLoginDetail(username, loginTime);

      if (!mounted) return; // Check if the widget is still mounted
      if (user['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/');
      } else if (user['role'] == 'cashier') {
        Navigator.pushReplacementNamed(context, '/cashier_dashboard');
      }
    } else {
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid username or password.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        child: Container(
          width: double.infinity,
          height:
              MediaQuery.of(
                context,
              ).size.height, // Adjust height to screen size
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              width: 500,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25), // Replaced withAlpha
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          currentTime,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentDate,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Username'),
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(onPressed: _login, child: Text('Login')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
