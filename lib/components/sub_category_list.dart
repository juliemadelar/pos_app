import 'package:flutter/material.dart';

class SubCategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> subCategories;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const SubCategoryList({
    super.key,
    required this.subCategories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Sub-Categories'),
      children:
          subCategories.map((subCategory) {
            return ListTile(
              title: Text(subCategory['name']),
              subtitle: Text(
                'Parent Category: ${subCategory['parent_category'] ?? 'Unknown'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit(subCategory),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(subCategory['id']),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
