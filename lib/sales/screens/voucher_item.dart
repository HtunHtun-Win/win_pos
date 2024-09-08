import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/sales/screens/sales_detail.dart';

class VoucherItem extends StatelessWidget {
  VoucherItem({super.key, required this.voucher});
  SaleModel voucher;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = fdate.format(date);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1,horizontal: 8),
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
            Text(finalDate),
            Text(voucher.customer!),
          ],
        ),
        onTap: () {
          Get.to(() => SalesDetail(voucher: voucher));
        },
      ),
    );
  }
}
