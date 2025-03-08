import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'db_helper.dart';
import 'package:logger/logger.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  UserManagementState createState() => UserManagementState();
}

class UserManagementState extends State<UserManagement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();
  final TextEditingController _roleController =
      TextEditingController(); // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar
      body: SingleChildScrollView(
        // Wrap content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Wrap with Form widget
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
              // Cashier Details and List Columns
              Row(
                children: [
                  // Column 1: Cashier Details Form
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Cashier Name',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter a name'
                                      : null,
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Cashier Username',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter a username'
                                      : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Cashier Password',
                          ),
                          obscureText: true,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter a password'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _addUser,
                              child: const Text('Add User'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _editCashier,
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _deleteCashier,
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  // Column 2: Cashier List Table
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getCashierDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                                      DataCell(
                                        Text(cashier['username'] ?? 'N/A'),
                                      ),
                                      DataCell(
                                        Text('******'),
                                      ), // Masked password
                                      DataCell(
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed:
                                                  () => _updateUser(cashier),
                                              child: Text('Edit'),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed:
                                                  () => _deleteUser(
                                                    cashier['username'],
                                                  ),
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
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Save Changes Button
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // Your existing code to load users...
    try {
      // Load users from the database
      // ...
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _logger.e('Error loading users: $e'); // Use logger
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      // Validate form
      try {
        await _dbHelper.addUser(
          _nameController.text,
          _usernameController.text,
          _passwordController.text,
          'cashier',
        );
        _logger.i('User added: ${_usernameController.text}');
        _clearControllers();
        if (mounted) {
          setState(() {}); // Refresh the UI after adding the user.
        }
      } catch (e) {
        _logger.e('Error adding user: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding user: $e')));
        }
      }
    }
  }

  Future<void> _deleteCashier() async {
    try {
      await _dbHelper.deleteUser(_usernameController.text);
      _logger.i('User deleted: ${_usernameController.text}');
      _clearControllers();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _logger.e('Error deleting user: $e');
      if (mounted) {
        _showErrorSnackBar(context, 'Error deleting user: $e');
      }
    }
  }

  Future<void> _editCashier() async {
    if (_formKey.currentState!.validate()) {
      // Validate form
      try {
        await _dbHelper.updateUser(_usernameController.text, {
          'name': _nameController.text,
          'password': _passwordController.text,
        });
        _logger.i('User updated: ${_usernameController.text}');
        _clearControllers();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        _logger.e('Error updating user: $e');
        if (mounted) {
          _showErrorSnackBar(context, 'Error updating user: $e');
        }
      }
    }
  }

  Future<void> _deleteUser(String username) async {
    try {
      await _dbHelper.deleteUser(username);
      _logger.i('User deleted: $username'); // Use logger
      if (mounted) {
        _loadUsers(); // Refresh the user list
      }
    } catch (e) {
      _logger.e('Error deleting user: $e'); // Use logger
    }
  }

  Future<void> _updateUser(Map<String, dynamic> cashier) async {
    try {
      bool updated =
          await showDialog(
            context: context,
            builder: (context) {
              if (!mounted) return Container(); // Check if mounted
              return _UserFormDialog(
                nameController: _nameController..text = cashier['name'] ?? '',
                usernameController:
                    _usernameController..text = cashier['username'] ?? '',
                passwordController:
                    _passwordController..text = cashier['password'] ?? '',
                roleController:
                    _roleController..text = 'cashier', // Assume cashier role
                onSave: () async {
                  await _dbHelper.updateUser(_usernameController.text, {
                    'password':
                        _passwordController.text.isEmpty
                            ? 'N/A'
                            : _passwordController.text,
                    'role':
                        _roleController.text.isEmpty
                            ? 'N/A'
                            : _roleController.text,
                    'name':
                        _nameController.text.isEmpty
                            ? 'N/A'
                            : _nameController.text,
                  });
                  _logger.i('User updated: ${_usernameController.text}');
                  if (mounted) {
                    _loadUsers();
                  }
                },
                onCancel: () {
                  if (mounted) {
                    Navigator.of(context).pop(false);
                  }
                },
              );
            },
          ) ??
          false;
      if (updated) {
        _clearControllers();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      _logger.e('Error updating user: $e'); // Use logger
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  Future<List<Map<String, dynamic>>> _getCashierDetails() async {
    Database db = await _dbHelper.database;
    return await db.query('users', where: 'role = ?', whereArgs: ['cashier']);
  }

  void _saveChanges() {
    // Implement the save changes functionality
    _logger.i('Changes saved');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _UserFormDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController roleController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _UserFormDialog({
    required this.nameController,
    required this.usernameController,
    required this.passwordController,
    required this.roleController,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('User Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: widget.usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: widget.passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextField(
            controller: widget.roleController,
            decoration: InputDecoration(labelText: 'Role'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onSave, child: Text('Save')),
        TextButton(onPressed: widget.onCancel, child: Text('Cancel')),
      ],
    );
  }
}
