import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/helpers/custom_route.dart';
import '/screen/splash_screen.dart';
import '/providers/auth.dart';
import '/screen/auth_screen.dart';
import '/screen/edit_products_scareen.dart';
import '/screen/orders_screen.dart';
import '/screen/user_products_screen.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'screen/cart_screen.dart';
import 'providers/products.dart';
import 'screen/product_detail_screen.dart';
import 'screen/products_overview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products('', '', []),
          update: (_, auth, previousProducts) => Products(
            auth.userId,
            auth.token,
            previousProducts == null ? [] : previousProducts.item,
          ),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (_, auth, previousOrders) => Orders(auth.userId, auth.token,
              previousOrders == null ? [] : previousOrders.order),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop App',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            // pageTransitionsTheme: PageTransitionsTheme(
            //   builders: {
            //     TargetPlatform.android: CustomPageTransitionBuilder(),
            //     TargetPlatform.iOS: CustomPageTransitionBuilder()
            //   },
            // ),
          ),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            ProductsOverviewScreen.routeName: (ctx) =>
                const ProductsOverviewScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductsScreen.routeName: (ctx) => const EditProductsScreen(),
          },
        ),
      ),
    );
  }
}
