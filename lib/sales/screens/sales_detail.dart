import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/controller/sales_detail_controller.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import '../../shop/shop_info_controller.dart';
import '../../shop/shop_model.dart';

// ignore: must_be_immutable
class SalesDetail extends StatelessWidget {
  SalesDetail({super.key, required this.voucher});
  SaleModel voucher;

  SalesDetailController salesDetailController =
      Get.put(SalesDetailController());
  ShopInfoController shopInfoController = Get.find();
  SalesController salesController = Get.put(SalesController());
  late ShopModel shopModel;

  @override
  Widget build(BuildContext context) {
    salesDetailController.getSaleDetail(voucher.id!);
    if (shopInfoController.shop.isNotEmpty) {
      shopModel = ShopModel.fromMap(shopInfoController.shop);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Detail"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () async {
                Get.defaultDialog(
                  title: "Delete!",
                  content: const Text("This process can't undo!"),
                  actions: [
                    TextButton(onPressed: (){
                      Get.back();
                    }, child: const Text("Cancel")),
                    TextButton(onPressed: () async{
                      int flag = await salesController.deleteSale(
                          voucher.id!,
                          salesDetailController.saleDatas,
                      );
                      salesController.getAllVouchers(
                          map: daterangeCalculate("today"),
                      );
                      if(flag==0){
                        Get.to(()=>SalesVoucherScreen());
                      }
                    }, child: const Text("Delete"))
                  ]
                );
              },
              icon: const Icon(
                Icons.delete,
              )),
          IconButton(
              onPressed: () async {
              },
              icon: const Icon(
                Icons.print,
                color: Colors.white,
              )),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Obx(() {
            return detailWidget();
          }))
        ],
      ),
    );
  }

  Widget detailWidget() {
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  shopModel.name ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  shopModel.phone ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  shopModel.address ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("INV No.")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.sale_no!)),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Customer")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.customer.toString())),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Sale staff")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.user.toString())),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text("Payment")),
                const Expanded(child: Text(":")),
                Expanded(flex: 3, child: Text(voucher.payment.toString())),
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
    List<Widget> itemList = [];
    for (int i = 0; i < salesDetailController.saleDatas.length; i++) {
      var data = salesDetailController.saleDatas[i];
      itemList.add(Row(
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
      children: itemList,
    );
  }
}
