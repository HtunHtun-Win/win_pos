import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/shop/shop_model.dart';

class PdfService {
  PdfService({
    required this.size,
    required this.shopModel,
    required this.voucher,
    required this.saleDetailModels,
  });

  PdfPageFormat size;
  ShopModel shopModel;
  SaleModel voucher;
  List<SaleDetailModel> saleDetailModels;

  Future<Uint8List> generatePdf() {
    DateTime date = DateTime.parse(voucher.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: size,
        build: (pw.Context context) {
          return [
            pw.Container(
                child: pw.Column(children: [
              pw.Column(
                children: [
                  pw.Text(
                    shopModel.name ?? "-",
                    style: const pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  pw.Text(
                    shopModel.phone ?? "-",
                    style: const pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  pw.Text(
                    shopModel.address ?? "-",
                    style: const pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("INV No.")),
                  pw.Expanded(child: pw.Text(":")),
                  pw.Expanded(flex: 3, child: pw.Text(voucher.sale_no!)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Customer")),
                  pw.Expanded(child: pw.Text(":")),
                  pw.Expanded(
                      flex: 3, child: pw.Text(voucher.customer.toString())),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Sale staff")),
                  pw.Expanded(child: pw.Text(":")),
                  pw.Expanded(flex: 3, child: pw.Text(voucher.user.toString())),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Payment")),
                  pw.Expanded(child: pw.Text(":")),
                  pw.Expanded(
                      flex: 3, child: pw.Text(voucher.payment.toString())),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Date")),
                  pw.Expanded(child: pw.Text(":")),
                  pw.Expanded(flex: 3, child: pw.Text(finalDate)),
                ],
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("No")),
                  pw.Expanded(flex: 2, child: pw.Text("Name")),
                  pw.Expanded(child: pw.Text("Qty")),
                  pw.Expanded(child: pw.Text("Price")),
                  pw.Expanded(child: pw.Text("Amount")),
                ],
              ),
              pw.Divider(),
              itemList(),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Container()),
                  pw.Expanded(flex: 2, child: pw.Text("Net Price")),
                  pw.Expanded(child: pw.Text(voucher.net_price.toString())),
                ],
              ),
              voucher.discount == 0
                  ? pw.Container()
                  : pw.Row(
                      children: [
                        pw.Expanded(flex: 3, child: pw.Container()),
                        pw.Expanded(flex: 2, child: pw.Text("Discount")),
                        pw.Expanded(
                            child: pw.Text(voucher.discount.toString())),
                      ],
                    ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Container()),
                  pw.Expanded(flex: 2, child: pw.Text("Total")),
                  pw.Expanded(child: pw.Text(voucher.total_price.toString())),
                ],
              ),
            ]))
          ];
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget itemList() {
    List<pw.Widget> itemList = [];
    for (int i = 0; i < saleDetailModels.length; i++) {
      var data = saleDetailModels[i];
      itemList.add(pw.Row(
        children: [
          pw.Expanded(child: pw.Text("${i + 1}")),
          pw.Expanded(flex: 2, child: pw.Text(data.product!)),
          pw.Expanded(child: pw.Text(data.quantity.toString())),
          pw.Expanded(child: pw.Text(data.price.toString())),
          pw.Expanded(
              child: pw.Text(
                  "${data.quantity! * int.parse(data.price.toString())}")),
        ],
      ));
    }
    return pw.Column(
      children: itemList,
    );
  }

  Future<void> savePdf(Uint8List byteList) async {
    final filePath = await getPath();
    final file = await File(filePath);
    await file.writeAsBytes(byteList);
  }

  Future<void> printPdf(Uint8List byteList) async {
    await Printing.layoutPdf(
      format: size,
      onLayout: (PdfPageFormat format) => byteList,
    );
  }

  Future<void> _getPermission() async {
    var state = await Permission.storage.status;
    if (state != PermissionStatus.granted) {
      await Permission.storage.request();
    }
  }

  Future<String> getPath() async {
    var filePath = '';
    String docSize = "A5";
    switch (size) {
      case PdfPageFormat.a4:
        docSize = "A4";
        break;
    }
    final fileName = "${voucher.sale_no}_$docSize.pdf";
    if (Platform.isAndroid) {
      await _getPermission();
      final directory = Directory('/storage/emulated/0/Download');
      filePath = "${directory.path}/$fileName";
    } else if (Platform.isLinux) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/$fileName';
    } else if (Platform.isWindows) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/$fileName';
    }
    return filePath;
  }
}
