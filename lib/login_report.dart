import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import DBHelper

class LoginReport extends StatelessWidget {
  const LoginReport({super.key});

  Future<List<Map<String, dynamic>>> fetchLoginDetails() async {
    final dbHelper = DBHelper();
    return await dbHelper.getLoginDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLoginDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No login details found.'));
          } else {
            final loginDetails = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Log In Time')),
                  DataColumn(label: Text('Log Out Time')),
                ],
                rows:
                    loginDetails.map((login) {
                      return DataRow(
                        cells: [
                          DataCell(Text(login['username'] ?? 'N/A')),
                          DataCell(
                            Text(login['name'] ?? 'N/A'),
                          ), // Ensure name is displayed
                          DataCell(Text(login['login_time'] ?? 'N/A')),
                          DataCell(Text(login['logout_time'] ?? 'N/A')),
                        ],
                      );
                    }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
