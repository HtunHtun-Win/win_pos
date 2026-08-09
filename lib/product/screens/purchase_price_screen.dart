import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import '../models/product_model.dart';

// ignore: unused_import
import 'dart:developer' as dev;

class PurchasePriceScreen extends StatelessWidget {
  final ProductModel product;

  PurchasePriceScreen(this.product, {super.key});

  final ProductController productController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    productController.getPurchasePriceLog(product.id!);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name.toString()),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.dialog(AlertDialog(
                title: const Text('Clear Zero Quantity'),
                content: const Text('This action affects all products.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await productController.clearZeroQty();
                      Get.back();
                      productController.getPurchasePriceLog(product.id!);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ));
            },
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Price History',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Recent purchase rates for this product.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                  Badge(
                    label: Text('${productController.purchasePriceLog.length}'),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                    textColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Qty',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Price',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Total',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () {
                  final items = productController.purchasePriceLog;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No price history found.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return _historyRow(
                        context,
                        item['quantity'].toString(),
                        item['price'].toString(),
                        '${item['quantity'] * item['price']}',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(
      BuildContext context, String qty, String price, String total) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Text(qty, style: theme.textTheme.bodyMedium)),
          Expanded(child: Text(price, style: theme.textTheme.bodyMedium)),
          Expanded(child: Text(total, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

Widget listTile(String qty, String price, String total) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(qty)),
        Expanded(child: Text(price)),
        Expanded(child: Text(total)),
      ],
    ),
  );
}

Widget rowTitle(String qty, String price, String total) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          qty,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          price,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          total,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        )),
      ],
    ),
  );
}
