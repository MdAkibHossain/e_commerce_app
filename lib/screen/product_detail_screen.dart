import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: SizedBox(
                height: 300,
                width: double.infinity,
                child: Hero(
                  tag: loadedProduct.id,
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${loadedProduct.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
