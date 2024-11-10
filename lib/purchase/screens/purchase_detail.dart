import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/purchase_detail_controller.dart';
import '../models/purchase_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:win_pos/setting/print_screen.dart';
import 'dart:typed_data';
import '../../shop/shop_info_controller.dart';
import '../../shop/shop_model.dart';

class PurchaseDetail extends StatelessWidget {
  PurchaseDetail({super.key, required this.voucher});
  PurchaseModel voucher;

  PurchaseDetailController purchaseDetailController =
      Get.put(PurchaseDetailController());
  ShopInfoController shopInfoController = Get.find();
  late ShopModel shopModel;

  @override
  Widget build(BuildContext context) {
    purchaseDetailController.getPurchaseDetail(voucher.id!);
    if (shopInfoController.shop.isNotEmpty) {
      shopModel = ShopModel.fromMap(shopInfoController.shop);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Detail"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: ()async{
                var pdfData = await buildPdf();
                Get.to(()=>PrintScreen(
                  pdfData: pdfData,
                  shopModel: shopModel,
                  purchaseModel: voucher,
                  purchaseItemList: purchaseDetailController.saleDatas,
                ));
              },
              icon: const Icon(Icons.print,color: Colors.white,)
          ),
        ],
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  shopModel?.name ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  shopModel?.phone ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  shopModel?.address ?? "-",
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

  Future<Uint8List> buildPdf() async{
    final doc = pw.Document();
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    //get sale item
    List<pw.Widget> myList = [];
    for(int i=0; i<purchaseDetailController.saleDatas.length; i++){
      var data = purchaseDetailController.saleDatas[i];
      myList.add(pw.Row(
        children: [
          pw.Expanded(child: pw.Text("${i+1}")),
          pw.Expanded(flex:2,child: pw.Text(data.product!)),
          pw.Expanded(child: pw.Text(data.quantity.toString())),
          pw.Expanded(child: pw.Text(data.price.toString())),
          pw.Expanded(child: pw.Text("${data.quantity! * int.parse(data.price.toString())}")),
        ],
      ));
    }
    doc.addPage(
        pw.Page(
            pageFormat: PdfPageFormat.roll80,
            build: (pw.Context context) {
              return pw.Theme(
                data: pw.ThemeData(
                  defaultTextStyle: const pw.TextStyle(fontSize:9),
                ),
                child: pw.Column(
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            shopModel?.name ?? "-",
                            style: const pw.TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            shopModel?.phone ?? "-",
                            style: const pw.TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            shopModel?.address ?? "-",
                            style: const pw.TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("INV No.")),
                          pw.Expanded(child: pw.Text(":")),
                          pw.Expanded(flex:3,child: pw.Text(voucher.purchaseNo!)),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("Customer")),
                          pw.Expanded(child: pw.Text(":")),
                          pw.Expanded(flex:3,child: pw.Text(voucher.supplier.toString())),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("Sale staff")),
                          pw.Expanded(child: pw.Text(":")),
                          pw.Expanded(flex:3,child: pw.Text(voucher.user.toString())),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("Payment")),
                          pw.Expanded(child: pw.Text(":")),
                          pw.Expanded(flex:3,child: pw.Text(voucher.payment.toString())),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("Date")),
                          pw.Expanded(child: pw.Text(":")),
                          pw.Expanded(flex:3,child: pw.Text(finalDate)),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text("No")),
                          pw.Expanded(flex:2,child: pw.Text("Name")),
                          pw.Expanded(child: pw.Text("Qty")),
                          pw.Expanded(child: pw.Text("Price")),
                          pw.Expanded(child: pw.Text("Amount")),
                        ],
                      ),
                      pw.Divider(),
                      pw.Column(children: myList),
                      pw.Divider(),
                      pw.Row(
                        children: [
                          pw.Expanded(flex:3,child: pw.Container()),
                          pw.Expanded(flex:2,child: pw.Text("Net Price")),
                          pw.Expanded(child: pw.Text(voucher.net_price.toString())),
                        ],
                      ),
                      voucher.discount==0? pw.Container() : pw.Row(
                        children: [
                          pw.Expanded(flex:3,child: pw.Container()),
                          pw.Expanded(flex:2,child: pw.Text("Discount")),
                          pw.Expanded(child: pw.Text(voucher.discount.toString())),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        children: [
                          pw.Expanded(flex:3,child: pw.Container()),
                          pw.Expanded(flex:2,child: pw.Text("Total")),
                          pw.Expanded(child: pw.Text(voucher.total_price.toString())),
                        ],
                      ),
                    ]
                ),
              ); // Center
            }));
    return doc.save();
  }
}
