import 'package:flutter/material.dart';
import 'package:pos_app/db_helper.dart'; // Import the db_helper

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
    required ListTile Function(dynamic context, dynamic item) itemBuilder,
  });

  void saveChanges() async {
    // Create an instance of DBHelper before calling the method
    final dbHelper = DBHelper();
    final categoryList =
        categories
            .map((map) => Category(id: map['id'], name: map['name']))
            .toList();
    await dbHelper.updateCategories(categoryList);
  }

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
                    onPressed: () {
                      onEdit(category);
                      saveChanges();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      onDelete(category['id']);
                      saveChanges();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
