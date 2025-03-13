import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key}); // Added named 'key' parameter

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Quantity: ${item.quantity}'),
            trailing: Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            ),
            onLongPress: () {
              cartProvider.removeItem(item.id);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${cartProvider.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement checkout functionality here
              },
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
