import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/sales/controller/sales_detail_controller.dart';
import 'package:win_pos/sales/models/sale_model.dart';

class SalesDetail extends StatelessWidget {
  SalesDetail({super.key, required this.voucher});
  SaleModel voucher;

  SalesDetailController salesDetailController =
      Get.put(SalesDetailController());

  @override
  Widget build(BuildContext context) {
    salesDetailController.getSaleDetail(voucher.id!);
    return Scaffold(
      appBar: AppBar(
        title: Text(voucher.sale_no!),
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

  Widget detailWidget(){
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("INV No.")),
                Expanded(child: Text(":")),
                Expanded(flex:3,child: Text(voucher.sale_no!)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Customer")),
                Expanded(child: Text(":")),
                Expanded(flex:3,child: Text(voucher.customer.toString())),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Sale staff")),
                Expanded(child: Text(":")),
                Expanded(flex:3,child: Text(voucher.user.toString())),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Payment")),
                Expanded(child: Text(":")),
                Expanded(flex:3,child: Text(voucher.payment.toString())),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Date")),
                Expanded(child: Text(":")),
                Expanded(flex:3,child: Text(finalDate)),
              ],
            ),
            const Divider(),
            const Row(
              children: [
                Expanded(child: Text("No")),
                Expanded(flex:2,child: Text("Name")),
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
                Expanded(flex:3,child: Container()),
                const Expanded(flex:2,child: Text("Net Price")),
                Expanded(child: Text(voucher.net_price.toString())),
              ],
            ),
            voucher.discount==0? Container() : Row(
              children: [
                Expanded(flex:3,child: Container()),
                const Expanded(flex:2,child: Text("Discount")),
                Expanded(child: Text(voucher.discount.toString())),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(flex:3,child: Container()),
                const Expanded(flex:2,child: Text("Total")),
                Expanded(child: Text(voucher.total_price.toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemList(){
    List<Widget> myList = [];
    for(int i=0; i<salesDetailController.saleDatas.length; i++){
      var data = salesDetailController.saleDatas[i];
      myList.add(Row(
        children: [
          Expanded(child: Text("${i+1}")),
          Expanded(flex:2,child: Text(data.product!)),
          Expanded(child: Text(data.quantity.toString())),
          Expanded(child: Text(data.price.toString())),
          Expanded(child: Text("${data.quantity! * int.parse(data.price.toString())}")),
        ],
      ));
    }
    return Column(children: myList,);
  }
}
