import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Import the Database class
import 'db_helper.dart'; // Import DBHelper

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  UserManagementState createState() => UserManagementState();
}

class UserManagementState extends State<UserManagement> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _addCashier() async {
    String name = _nameController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    await _dbHelper.addUser(name, username, password, 'cashier');
    setState(() {});
  }

  void _editCashier() async {
    String name = _nameController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    await _dbHelper.updateUser(username, {'name': name, 'password': password});
    setState(() {});
  }

  void _deleteCashier() async {
    String username = _usernameController.text;

    await _dbHelper.deleteUser(username);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _getCashierDetails() async {
    Database db = await _dbHelper.database;
    return await db.query('users', where: 'role = ?', whereArgs: ['cashier']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        automaticallyImplyLeading: false, // Remove the back button
=======
      automaticallyImplyLeading: false, // Remove the back button
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
        title: Text('User Management'),
      ),
      body: Padding(
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
<<<<<<< HEAD
                Expanded(child: Text('Admin Username: admin')),
                Expanded(child: Text('Admin Password: password123')),
=======
                Expanded(
                  child: Text('Admin Username: admin'),
                ),
                Expanded(
                  child: Text('Admin Password: ******'), // Masked password
                ),
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
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
                Expanded(
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _addCashier,
                        child: Text('Add'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _editCashier,
                        child: Text('Edit'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _deleteCashier,
                        child: Text('Delete'),
                      ),
                    ],
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
                    ],
                    rows: snapshot.data!.map((cashier) {
                      return DataRow(cells: [
                        DataCell(Text(cashier['name'])),
                        DataCell(Text(cashier['username'])),
                        DataCell(Text('******')), // Masked password
                      ]);
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
