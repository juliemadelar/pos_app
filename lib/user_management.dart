import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Import the Database class
import 'db_helper.dart'; // Import DBHelper
import 'package:logger/logger.dart'; // Add this import

class UserManagement extends StatefulWidget {
  const UserManagement({super.key}); // Convert 'key' to a super parameter

  @override
  UserManagementState createState() => UserManagementState(); // Make the type public
}

class UserManagementState extends State<UserManagement> {
  // Make the type public
  final DBHelper _dbHelper =
      DBHelper(); // Ensure using the same DBHelper instance
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final Logger _logger = Logger(); // Add this line

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Load users from the database
      // ...
      setState(() {});
    } catch (e) {
      _logger.e('Error loading users: $e'); // Use logger
    }
  }

  Future<void> _addUser() async {
    try {
      await _dbHelper.addUser(
        _nameController.text.isEmpty ? 'N/A' : _nameController.text,
        _usernameController.text.isEmpty ? 'N/A' : _usernameController.text,
        _passwordController.text.isEmpty ? 'N/A' : _passwordController.text,
        _roleController.text.isEmpty ? 'N/A' : _roleController.text,
      );
      _logger.i('User added: ${_usernameController.text}'); // Use logger
      _loadUsers(); // Refresh the user list
    } catch (e) {
      _logger.e('Error adding user: $e'); // Use logger
    }
  }

  Future<void> _deleteUser(String username) async {
    try {
      await _dbHelper.deleteUser(username);
      _logger.i('User deleted: $username'); // Use logger
      _loadUsers(); // Refresh the user list
    } catch (e) {
      _logger.e('Error deleting user: $e'); // Use logger
    }
  }

  Future<void> _updateUser() async {
    try {
      await _dbHelper.updateUser(_usernameController.text, {
        'password':
            _passwordController.text.isEmpty ? 'N/A' : _passwordController.text,
        'role': _roleController.text.isEmpty ? 'N/A' : _roleController.text,
        'name': _nameController.text.isEmpty ? 'N/A' : _nameController.text,
      });
      _logger.i('User updated: ${_usernameController.text}'); // Use logger
      _loadUsers(); // Refresh the user list
    } catch (e) {
      _logger.e('Error updating user: $e'); // Use logger
    }
  }

  Future<void> _saveChanges() async {
    try {
      await _updateUser();
      _logger.i('Changes saved for user: ${_usernameController.text}');
    } catch (e) {
      _logger.e('Error saving changes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getCashierDetails() async {
    Database db = await _dbHelper.database;
    return await db.query('users', where: 'role = ?', whereArgs: ['cashier']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar
      body: SingleChildScrollView(
        // Wrap content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Details Header
            Text(
              'Admin Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Admin Details Row
            Row(
              children: [
                Expanded(child: Text('Admin Username: admin')),
                Expanded(
                  child: Text('Admin Password: ******'), // Masked password
                ),
              ],
            ),
            SizedBox(height: 20),
            // Cashier Details Header
            Text(
              'Cashier Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Cashier Details Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Cashier Name'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Cashier Username'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Cashier Password'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Cashier Login Details Table
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getCashierDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No cashiers found.');
                } else {
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Username')),
                      DataColumn(label: Text('Password')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        snapshot.data!.map((cashier) {
                          return DataRow(
                            cells: [
                              DataCell(Text(cashier['name'] ?? 'N/A')),
                              DataCell(Text(cashier['username'] ?? 'N/A')),
                              DataCell(Text('******')), // Masked password
                              DataCell(
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _nameController.text =
                                            cashier['name'] ?? '';
                                        _usernameController.text =
                                            cashier['username'] ?? '';
                                        _passwordController.text =
                                            cashier['password'] ?? '';
                                        _roleController.text = 'cashier';
                                        _updateUser(); // Save changes to the database
                                      },
                                      child: Text('Edit'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteUser(cashier['username']);
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addUser, child: Text('Add User')),
            SizedBox(height: 20),
            // Save Changes Button
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
