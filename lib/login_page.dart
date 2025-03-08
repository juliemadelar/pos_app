import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart'; // Import the Database class
import 'db_helper.dart';
import 'cashier_dashboard.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    bool hasUsers = await _dbHelper.hasUsers();
    bool hasProducts = await _dbHelper.hasProducts();

    if (!hasUsers || !hasProducts) {
      await _dbHelper.createAndSaveProductTables();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database initialized with default data.')),
      );
    }
  }

  Future<void> addUser(String name, String username, String password, String role) async {
    Database db = await _dbHelper.database;
    await db.insert('users', {'username': username, 'password': password, 'role': role, 'name': name});
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    try {
      var user = await _dbHelper.getUser(username, password);
      if (user != null) {
        if (user['role'] == 'cashier') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CashierDashboard()),
          );
        } else if (user['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Added SingleChildScrollView
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Adjust height to screen size
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
                color: Colors.white.withOpacity(0.1),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
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
                        ElevatedButton(
                          onPressed: _login,
                          child: Text('Login'),
                        ),
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