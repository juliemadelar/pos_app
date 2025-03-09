import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  Future<void> showEditDialog(
    BuildContext context,
    Map<String, dynamic> subCategory,
  ) async {
    final TextEditingController nameController = TextEditingController(
      text: subCategory['name'],
    );
    final TextEditingController parentCategoryController =
        TextEditingController(text: subCategory['parent_category']);
    String? imagePath = subCategory['image'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Sub-Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: parentCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Category',
                  ),
                ),
                const SizedBox(height: 10),
                imagePath != null
                    ? Image.file(File(imagePath!))
                    : const Icon(Icons.image_not_supported),
                TextButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      imagePath = pickedFile.path;
                      (context as Element).markNeedsBuild(); // Update UI
                    }
                  },
                  child: const Text('Pick Image'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                onEdit({
                  'id': subCategory['id'],
                  'name': nameController.text,
                  'parent_category': parentCategoryController.text,
                  'image': imagePath,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Sub-Categories'),
      children:
          subCategories.map((subCategory) {
            return ListTile(
              leading:
                  subCategory['image'] != null
                      ? Image.file(File(subCategory['image']))
                      : const Icon(Icons.image_not_supported),
              title: Text(subCategory['name']),
              subtitle: Text(
                'Parent Category: ${subCategory['parent_category'] ?? 'Unknown'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showEditDialog(context, subCategory),
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
