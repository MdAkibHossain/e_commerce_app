import 'package:flutter/material.dart';
import '/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> product;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.product,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? userId;
  final String? authToken;

  Orders(
    this.userId,
    this.authToken,
    this._orders,
  );

  List<OrderItem> get order {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];

    final extractedDataResponseBody = json.decode(response.body);

    if (extractedDataResponseBody == null) {
      return;
    }
    final extractedData = extractedDataResponseBody as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          product: (orderData['product'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  price: item['price'],
                  quantity: item['quantity'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'product': cartProduct
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList()
        }));

    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)['name'],
        amount: total,
        product: cartProduct,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
