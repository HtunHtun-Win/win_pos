import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/purchase_detail_controller.dart';
import '../models/purchase_model.dart';

class PurchaseDetail extends StatelessWidget {
  PurchaseDetail({super.key, required this.voucher});
  PurchaseModel voucher;

  PurchaseDetailController purchaseDetailController =
      Get.put(PurchaseDetailController());

  @override
  Widget build(BuildContext context) {
    purchaseDetailController.getPurchaseDetail(voucher.id!);
    return Scaffold(
      appBar: AppBar(
        title: Text(voucher.purchaseNo!),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: Obx(() {
              return detailWidget();
            }))
          ],
        ),
      ),
    );
  }

  Widget detailWidget() {
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text("INV No.")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.purchaseNo!)),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Supplier")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.supplier.toString())),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Staff")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.user.toString())),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Date")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(finalDate)),
              ],
            ),
            const Divider(),
            const Row(
              children: [
                Expanded(child: Text("No")),
                Expanded(flex: 2, child: Text("Name")),
                Expanded(child: Text("Qty")),
                Expanded(child: Text("Price")),
                Expanded(child: Text("Amount")),
              ],
            ),
            const Divider(),
            itemList(),
            const Divider(),
            Row(
              children: [
                Expanded(flex: 3, child: Container()),
                const Expanded(flex: 2, child: Text("Net Price")),
                Expanded(child: Text(voucher.net_price.toString())),
              ],
            ),
            voucher.discount == 0
                ? Container()
                : Row(
                    children: [
                      Expanded(flex: 3, child: Container()),
                      const Expanded(flex: 2, child: Text("Discount")),
                      Expanded(child: Text(voucher.discount.toString())),
                    ],
                  ),
            const Divider(),
            Row(
              children: [
                Expanded(flex: 3, child: Container()),
                const Expanded(flex: 2, child: Text("Total")),
                Expanded(child: Text(voucher.total_price.toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemList() {
    List<Widget> myList = [];
    for (int i = 0; i < purchaseDetailController.saleDatas.length; i++) {
      var data = purchaseDetailController.saleDatas[i];
      myList.add(Row(
        children: [
          Expanded(child: Text("${i + 1}")),
          Expanded(flex: 2, child: Text(data.product!)),
          Expanded(child: Text(data.quantity.toString())),
          Expanded(child: Text(data.price.toString())),
          Expanded(
              child:
                  Text("${data.quantity! * int.parse(data.price.toString())}")),
        ],
      ));
    }
    return Column(
      children: myList,
    );
  }
}
