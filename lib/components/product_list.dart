import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Add this import

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>, String) onEdit;
  final Function(int) onDelete;

  const ProductList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required void Function(Map<String, dynamic> product) onViewDetails,
  });

  Future<void> showEditDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: product['name']),
                decoration: InputDecoration(labelText: 'Product Name'),
                onChanged: (value) {
                  product['name'] = value;
                },
              ),
              TextField(
                controller: TextEditingController(
                  text: product['sub_category'],
                ),
                decoration: InputDecoration(labelText: 'Sub Category'),
                onChanged: (value) {
                  product['sub_category'] = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    product['image'] = image?.path;
                    (context as Element).markNeedsBuild(); // Update UI
                  }
                },
                child: Text('Change Image'),
              ),
              if (product['image'] != null)
                Image.file(File(product['image']), width: 100, height: 100),
            ],
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
                onEdit(product, image?.path ?? '');
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
      title: const Text('Products'),
      children:
          products.map((product) {
            return ListTile(
              leading:
                  product.containsKey('image')
                      ? Image.file(
                        File(product['image']),
                        width: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.png', // Replace with your placeholder image
                            width: 200,
                          );
                        },
                      )
                      : null,
              title: Text(product['name']),
              subtitle: Text(
                'Parent Category: ${product['parent_category'] ?? 'Unknown'}\nSub Category: ${product['sub_category'] ?? 'Unknown'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed:
                        () => showEditDialog(
                          context,
                          product,
                        ), // Update this line
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(product['id']),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
