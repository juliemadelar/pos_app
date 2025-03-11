import 'package:flutter/material.dart';

class SizesList extends StatelessWidget {
  final List<Map<String, dynamic>> sizesList;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;

  const SizesList({
    required this.sizesList,
    this.onEdit,
    this.onDelete,
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
        return ListTile(
          title: Text(item['name'] ?? item['size'] ?? 'Size ${index + 1}'),
          subtitle: Text('Price: ${item['price']}'),
          trailing:
              (onEdit != null || onDelete != null)
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEdit!(item),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDelete!(item['id']),
                        ),
                    ],
                  )
                  : null,
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

  const SizesScreen({
    required this.productId,
    required this.sizesList,
    this.onEdit,
    this.onDelete,
    this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Size Selection')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizesList(
            sizesList: sizesList,
            onEdit: onEdit,
            onDelete: onDelete,
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
