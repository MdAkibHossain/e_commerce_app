import 'dart:convert';
import 'package:flutter/material.dart';
import '/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _item = [];

  final String? authToken;
  final String? userId;
  Products(this.userId, this.authToken, this._item);

  List<Product> get item {
    return [..._item];
  }

  List<Product> get favoriteItem {
    return _item.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _item.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedDataResponseBody = json.decode(response.body);
      if (extractedDataResponseBody == null) {
        return;
      }
      final url2 = Uri.parse(
          'https://fluttter-test-default-rtdb.firebaseio.com/userFevorites/$userId.json?auth=$authToken');

      final favoriteResponse = await http.get(url2);
      final favoriteData = json.decode(favoriteResponse.body);

      final extractedData = extractedDataResponseBody as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId.toString(),
          title: prodData['title'].toString(),
          description: prodData['description'].toString(),
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'].toString(),
        ));
      });
      _item = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'descripttion': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        description: product.description,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _item.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _item.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://fluttter-test-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'descripttion': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));

      _item[prodIndex] = newProduct;
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://fluttter-test-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _item.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _item[existingProductIndex];
    _item.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _item.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not deleted');
    }
    existingProduct = null;
  }
}
