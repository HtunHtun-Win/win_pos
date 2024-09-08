import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';

import 'purchase_detail.dart';

class PVoucherItem extends StatelessWidget {
  PVoucherItem({super.key, required this.voucher});
  PurchaseModel voucher;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = fdate.format(date);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 3,
          )),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(voucher.purchaseNo!),
            Text(voucher.total_price.toString()),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(finalDate),
            Text(voucher.supplier!),
          ],
        ),
        onTap: () {
          Get.to(() => PurchaseDetail(voucher: voucher));
        },
      ),
    );
  }
}
