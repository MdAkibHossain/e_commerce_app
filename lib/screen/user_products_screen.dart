import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/app_drawer.dart';
import '/providers/products.dart';
import '/screen/edit_products_scareen.dart';
import '/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = '/user_products';

  Future<void> _refreshProducts(BuildContext context) async {
    Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductsScreen.routeName);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.item.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductsItem(
                                id: productsData.item[i].id,
                                title: productsData.item[i].title,
                                imageUrl: productsData.item[i].imageUrl,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
