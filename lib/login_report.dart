import 'package:flutter/material.dart';
import 'login_data.dart'; // Import login data

class LoginReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Report'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Cashier Username')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time In')),
            DataColumn(label: Text('Time Out')),
            DataColumn(label: Text('Cashier Name')),
          ],
          rows: LoginData.list.map((login) {
            return DataRow(cells: [
              DataCell(Text(login.username)),
              DataCell(Text(login.date)),
              DataCell(Text(login.timeIn)),
              DataCell(Text(login.timeOut)),
              DataCell(Text(login.cashierName)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
