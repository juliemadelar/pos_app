import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>, String) onEdit;
  final Function(int) onDelete;
  final void Function(Map<String, dynamic>) onViewDetails;
  final ListTile Function(BuildContext, Map<String, dynamic>) itemBuilder;

  const ProductList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
    required this.itemBuilder,
  });

  Future<void> showEditDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    final TextEditingController nameController = TextEditingController(
      text: product['name'],
    );
    final TextEditingController subCategoryController = TextEditingController(
      text: product['sub_category'],
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                      onChanged: (value) {
                        product['name'] = value;
                      },
                    ),
                    TextField(
                      controller: subCategoryController,
                      decoration: InputDecoration(labelText: 'Sub Category'),
                      onChanged: (value) {
                        product['sub_category'] = value;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            product['image'] = image?.path;
                          });
                        }
                      },
                      child: Text('Change Image'),
                    ),
                    if (product['image'] != null)
                      Image.file(
                        File(product['image']),
                        width: 100,
                        height: 100,
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    onEdit({
                      'id': product['id'],
                      'name': nameController.text,
                      'sub_category': subCategoryController.text,
                      'image': product['image'],
                    }, image?.path ?? '');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
      children: [
        Flexible(
          fit: FlexFit.loose, // Use FlexFit.loose
          child: SizedBox(
            height: 400, // Provide a height constraint
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 4, // Add elevation for shadow
                  child: ListTile(
                    leading:
                        product['image'] != null &&
                                File(product['image']).existsSync()
                            ? Image.file(
                              File(product['image']),
                              width: 50,
                              height: 50,
                            )
                            : Image.asset(
                              'assets/placeholder.png',
                              width: 50,
                              height: 50,
                            ),
                    title: Text(product['name']),
                    subtitle: Text('Sub-Category: ${product['sub_category']}'),
                    trailing: SizedBox(
                      width: 100, // Adjust the width as needed
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => showEditDialog(context, product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => onDelete(product['id']),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => onViewDetails(product),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
