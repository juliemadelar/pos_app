import 'package:flutter/material.dart';

class SizesList extends StatelessWidget {
  final List<Map<String, dynamic>> sizesList;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;
  final Map<int, String> productNames; // Add this to show product names

  const SizesList({
    required this.sizesList,
    this.onEdit,
    this.onDelete,
    required this.productNames, // Make this required
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (sizesList.isEmpty) {
      return const Center(child: Text('No sizes available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sizesList.length,
      itemBuilder: (context, index) {
        final item = sizesList[index];
        final productId = item['product_id'] as int?;
        final productName =
            productId != null
                ? productNames[productId] ?? 'Unknown Product'
                : 'Unknown Product';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(item['name'] ?? item['size'] ?? 'Size ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: ₱${item['price']}'),
                Text(
                  'Product: $productName',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing:
                (onEdit != null || onDelete != null)
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit size, price, and product',
                            onPressed: () => onEdit!(item),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete size',
                            onPressed: () => onDelete!(item['id']),
                          ),
                      ],
                    )
                    : null,
          ),
        );
      },
    );
  }
}

// Example usage widget
class SizesScreen extends StatelessWidget {
  final int productId;
  final List<Map<String, dynamic>> sizesList;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;
  final VoidCallback? onAdd;
  final Map<int, String> productNames; // Add this parameter

  const SizesScreen({
    required this.productId,
    required this.sizesList,
    this.onEdit,
    this.onDelete,
    this.onAdd,
    required this.productNames, // Make this required
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizesList(
            sizesList: sizesList,
            onEdit: onEdit,
            onDelete: onDelete,
            productNames: productNames,
          ),
        ),
      ),
      floatingActionButton:
          onAdd != null
              ? FloatingActionButton(
                onPressed: onAdd,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
