import 'package:flutter/material.dart';
import 'dart:io';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>, String) onEdit;
  final Function(int) onDelete;

  const ProductList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

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
                    onPressed: () => onEdit(product, ''),
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
