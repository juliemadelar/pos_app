import 'package:flutter/material.dart';

class SizesList extends StatefulWidget {
  final int productId;
  final List<Map<String, dynamic>> sizesList; // Changed to sizesList
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;
  const SizesList({
    required this.productId,
    required this.sizesList,
    required this.onEdit,
    required this.onDelete,
    super.key,
    required ListTile Function(dynamic context, dynamic item) itemBuilder,
  });

  @override
  State<SizesList> createState() => _SizesListState();
}

class _SizesListState extends State<SizesList> {
  // Removed _fetchSizesList - data is now passed directly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          widget.sizesList.isEmpty
              ? const Center(child: Text('Add-In List is empty'))
              : DataTable(
                columns: const [
                  DataColumn(label: Text('ID')), // Added ID column
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Product')),
                ],
                rows:
                    widget.sizesList
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
