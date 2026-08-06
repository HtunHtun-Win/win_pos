import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/payment/controller/payment_controller.dart';
import 'package:win_pos/payment/models/payment_model.dart';
import 'package:win_pos/payment/screens/payment_add_screen.dart';
import 'package:win_pos/payment/screens/payment_edit_screen.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});
  final PaymentController paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => PaymentAddScreen()),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Obx(() {
        final items = paymentController.payments.where((p) => p.id != 1).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'No payment methods found.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _paymentCard(context, items[index]);
                  },
                ),
        );
      }),
    );
  }

  Widget _paymentCard(BuildContext context, PaymentModel payment) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: Text(
          payment.name.toString(),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(payment.description.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => PaymentEditScreen(payment));
              },
              icon: const Icon(Icons.edit),
              color: theme.colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete'),
                    content: const Text('Are you sure you want to delete this payment method?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          paymentController.deletePayment(payment.id);
                          Get.back();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
