import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/screens/product_ledger_screen.dart';
import 'purchase_price_screen.dart';
import '../models/product_model.dart';

// ignore: unused_import
import 'dart:developer' as dev;

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => PurchasePriceScreen(product),
                transition: Transition.zoom,
                duration: const Duration(milliseconds: 300),
              );
            },
            icon: const Icon(Icons.price_change_rounded),
          ),
          IconButton(
            onPressed: () {
              Get.to(
                () => ProductLedgerScreen(id: product.id!),
                transition: Transition.zoom,
                duration: const Duration(milliseconds: 300),
              );
            },
            icon: const Icon(Icons.event_note),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.toString(),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product details and pricing information.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _infoBadge(
                          context, 'Quantity', product.quantity.toString()),
                      _infoBadge(context, 'Category',
                          product.category_name.toString()),
                      _infoBadge(context, 'Purchase',
                          product.purchase_price.toString()),
                      _infoBadge(
                          context, 'Sale', product.sale_price.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _detailCard(
            context,
            title: 'Code',
            value: product.code.toString(),
          ),
          _detailCard(
            context,
            title: 'Description',
            value: product.description?.isNotEmpty == true
                ? product.description.toString()
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 28,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(BuildContext context,
      {required String title, required String value}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
