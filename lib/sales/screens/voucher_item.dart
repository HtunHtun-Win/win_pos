import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/sales/screens/sales_detail.dart';

class VoucherItem extends StatelessWidget {
  VoucherItem({super.key, required this.voucher, required this.cName});
  SaleModel voucher;
  String cName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
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
            Text(voucher.sale_no!),
            Text(voucher.total_price.toString()),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(voucher.created_at!),
            Text(cName),
          ],
        ),
        onTap: () {
          Get.to(() => SalesDetail(voucher: voucher));
        },
      ),
    );
  }
}
