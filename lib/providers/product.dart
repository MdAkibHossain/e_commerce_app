import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String? authToken, String? userId) async {
    final _oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/userFevorites/$userId/$id.json?auth=$authToken');
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      if (response.statusCode >= 400) {
        _setFavValue(_oldStatus);
      }
    } catch (error) {
      _setFavValue(_oldStatus);
    }
  }
}
