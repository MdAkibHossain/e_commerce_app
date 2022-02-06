import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/products.dart';
import '/providers/cart.dart';
import '/screen/cart_screen.dart';
import '/widgets/app_drawer.dart';
import '/widgets/badge.dart';
import '/widgets/products_grid.dart';

enum FilterOftion {
  favorite,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);
  static const routeName = '/productOverviewScreen';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorite = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (FilterOftion selectedValue) {
                setState(() {
                  if (selectedValue == FilterOftion.favorite) {
                    _showOnlyFavorite = true;
                  } else {
                    _showOnlyFavorite = false;
                  }
                });
              },
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      child: Text('Show Favorite'),
                      value: FilterOftion.favorite,
                    ),
                    const PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOftion.all,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, Widget? ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
              color: Colors.transparent,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(
              showFavorite: _showOnlyFavorite,
            ),
    );
  }
}
