import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          TextButton(
            onPressed: () => _confirmClear(context),
            child: const Text('Clear cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                return ListView(
                  children: [
                    for (final b in cart.items)
                      ListTile(
                        title: Text(b.title),
                        subtitle: Text('${b.author} · ${b.price} ₸'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('×${cart.qtyOf(b)}'),
                            IconButton(
                              tooltip: 'Add one',
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  context.read<Cart>().increment(b),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.close),
                              onPressed: () => context.read<Cart>().remove(b),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Consumer<Cart>(
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments_outlined),
                SizedBox(width: 8),
                Text('Total'),
              ],
            ),
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [child!, const Spacer(), Text('${cart.total} ₸')],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmClear(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Clear the cart?'),
        content: const Text('Every book will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      );
    },
  );
  if (ok == true && context.mounted) {
    context.read<Cart>().clear();
  }
}
