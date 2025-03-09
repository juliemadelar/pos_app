import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Categories'),
      children:
          categories.map((category) {
            return ListTile(
              title: Text(category['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit(category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(category['id']),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
