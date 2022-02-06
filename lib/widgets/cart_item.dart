import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart.dart';

class CartItem extends StatelessWidget {
  const CartItem(
      {Key? key,
      required this.id,
      required this.productId,
      required this.title,
      required this.puantity,
      required this.price})
      : super(key: key);
  final String id;
  final String productId;
  final String title;
  final int puantity;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (directtion) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you wan to delete this item?'),
            actions: [
              FlatButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total : \$${price * puantity}'),
            trailing: Text('$puantity x'),
          ),
        ),
      ),
    );
  }
}
