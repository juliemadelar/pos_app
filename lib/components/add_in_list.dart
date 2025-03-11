import 'package:flutter/material.dart';

class AddInList extends StatefulWidget {
  final int productId;
  final List<Map<String, dynamic>> addInList; // Changed to addInList
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;
  const AddInList({
    required this.productId,
    required this.addInList,
    required this.onEdit,
    required this.onDelete,
    super.key,
    required ListTile Function(dynamic context, dynamic item) itemBuilder,
  });

  @override
  State<AddInList> createState() => _AddInListState();
}

class _AddInListState extends State<AddInList> {
  // Removed _fetchAddInList - data is now passed directly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          widget.addInList.isEmpty
              ? const Center(child: Text('Add-In List is empty'))
              : DataTable(
                columns: const [
                  DataColumn(label: Text('ID')), // Added ID column
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Product')),
                ],
                rows:
                    widget.addInList
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(
                                Text(item['id'].toString()),
                              ), // Added ID cell
                              DataCell(Text(item['name'])),
                              DataCell(Text(item['price'].toString())),
                              DataCell(Text(item['parent_product'].toString())),
                            ],
                          ),
                        )
                        .toList(),
              ),
    );
  }
}
