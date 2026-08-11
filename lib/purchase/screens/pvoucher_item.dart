import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/functions/pretty_date_format.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';

import 'purchase_detail.dart';

// ignore: must_be_immutable
class PVoucherItem extends StatelessWidget {
  PVoucherItem({super.key, required this.voucher});
  PurchaseModel voucher;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.inversePrimary,
          //   width: 1,
          // ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            )
          ]
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(voucher.purchaseNo!),
            Text("${voucher.total_price.toString()} MMK"),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(prettyDate(voucher.created_at.toString())),
            SizedBox(
              width: 120,
              child: Text(voucher.supplier!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        onTap: () {
          Get.to(() => PurchaseDetail(voucher: voucher));
        },
      ),
    );
  }
}
