import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addItem(String name, double price, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.name == name);

    if (existingIndex >= 0) {
      // If item exists, update the quantity
      _items[existingIndex] = CartItem(
        id: _items[existingIndex].id,
        name: name,
        price: price,
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // If item doesn't exist, add it to the cart
      _items.add(
        CartItem(
          id: DateTime.now().toString(),
          name: name,
          price: price,
          quantity: quantity,
        ),
      );
    }
    notifyListeners(); // Notify listeners about the change
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
