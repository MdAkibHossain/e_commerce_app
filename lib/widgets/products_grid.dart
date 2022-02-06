import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/product_item.dart';
import '/providers/products.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({Key? key, required this.showFavorite}) : super(key: key);
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavorite ? productsData.favoriteItem : productsData.item;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: const ProductItem(),
      ),
      itemCount: products.length,
    );
  }
}
