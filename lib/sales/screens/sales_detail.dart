import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              print(salesDetailController.saleDatas);
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: Obx(() {
              return ListView.builder(
                itemCount: salesDetailController.saleDatas.length,
                itemBuilder: (context, index) {
                  var data = salesDetailController.saleDatas[index];
                  return Text("one");
                },
              );
            }))
          ],
        ),
      ),
    );
  }
}
