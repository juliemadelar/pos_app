import 'package:flutter/material.dart';
import 'sales_data.dart'; // Import sales data

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  SalesReportState createState() => SalesReportState();
}

class SalesReportState extends State<SalesReport> {
  DateTimeRange? dateRange;
  String? selectedUsername;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
<<<<<<< HEAD
          automaticallyImplyLeading: false, // Remove the back button
=======
        automaticallyImplyLeading: false, // Remove the back button
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
          title: Text('Sales Report'),
          bottom: TabBar(
            tabs: [Tab(text: 'By Date Range'), Tab(text: 'By Username')],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Sales report by date range
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dateRange = picked;
                        });
                      }
                    },
                    child: Text('Select Date Range'),
                  ),
                  if (dateRange != null)
                    Text(
                      'Selected range: ${dateRange!.start} - ${dateRange!.end}',
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          SalesData.getSalesByDateRange(dateRange).length,
                      itemBuilder: (context, index) {
                        final sale =
                            SalesData.getSalesByDateRange(dateRange)[index];
                        return ListTile(
                          title: Text(
                            'Date: ${sale.date}, Amount: \$${sale.amount}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2: Sales report by username
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Username'),
                    value: selectedUsername,
                    items:
                        SalesData.usernames.map((username) {
                          return DropdownMenuItem<String>(
                            value: username,
                            child: Text(username),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUsername = value;
                      });
                    },
                  ),
                  if (selectedUsername != null)
                    ElevatedButton(
                      onPressed: () async {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            dateRange = picked;
                          });
                        }
                      },
                      child: Text('Select Date Range'),
                    ),
                  if (dateRange != null)
                    Text(
                      'Selected range: ${dateRange!.start} - ${dateRange!.end}',
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          SalesData.getSalesByUsernameAndDateRange(
                            selectedUsername,
                            dateRange,
                          ).length,
                      itemBuilder: (context, index) {
                        final sale =
                            SalesData.getSalesByUsernameAndDateRange(
                              selectedUsername,
                              dateRange,
                            )[index];
                        return ListTile(
                          title: Text(
                            'Date: ${sale.date}, Amount: \$${sale.amount}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
