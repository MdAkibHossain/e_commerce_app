import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem(
      {required this.id,
      required this.title,
      required this.price,
      required this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _item = {};

  Map<String, CartItem> get item {
    return {..._item};
  }

  int get itemCount {
    return _item.length;
  }

  double get totalAmount {
    double total = 0;
    _item.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_item.containsKey(productId)) {
      _item.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _item.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
  }

  void removeItem(String productId) {
    _item.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_item.containsKey(productId)) {
      return;
    }
    if (_item[productId]!.quantity > 1) {
      _item.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _item.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _item = {};
    notifyListeners();
  }
}
