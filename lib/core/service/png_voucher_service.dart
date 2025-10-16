import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/shop/shop_model.dart';

class PngVoucherService {
  PngVoucherService({
    required this.shopModel,
    required this.voucher,
    required this.saleDetailModels,
  });

  final ShopModel shopModel;
  final SaleModel voucher;
  final List<SaleDetailModel> saleDetailModels;

  /// Generate PNG receipt (80 mm width)
  Future<Uint8List> generatePng() async {
    // 🗓️ Date formatting
    final date = DateTime.parse(voucher.created_at.toString());
    // final fdate =  DateFormat("yyyy-MM-dd h:mm a");
    // final finalDate = fdate.format(date);

    final shopName = shopModel.name;
    final phone = shopModel.phone;
    final address = shopModel.address;

    // 🖼️ Build printable image with voucher layout
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    // final paint = Paint();
    var textStyle = const TextStyle(fontSize: 26, color: Colors.black);
    var boldStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    double y = 20;

    void drawText(
        String text, {
          TextStyle? style,
          TextAlign align = TextAlign.left,
        }) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: align,
        text: TextSpan(text: text, style: style ?? textStyle),
      );
      textPainter.layout(maxWidth: 570);
      double x = 0;
      if (align == TextAlign.center) x = (580 - textPainter.width) / 2;
      if (align == TextAlign.right) x = 580 - textPainter.width;
      textPainter.paint(canvas, Offset(x, y));
      y += textPainter.height + 8;
    }

    void drawHeaderColumn(
        String text1,
        String text2,{
          TextStyle? style,
        }) {
      // Define column X positions
      const double text1X = 0;
      const double text2X = 150;

      // Max width for each column
      const double text1MaxWidth = 200;
      const double text2MaxWidth = 400;

      // Draw product text1 (left-aligned)
      final text1Painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text1, style: style ?? textStyle),
      );
      text1Painter.layout(maxWidth: text1MaxWidth);
      text1Painter.paint(canvas, Offset(text1X, y));

      // Draw price (right-aligned)
      final text2Painter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        text: TextSpan(text: text2, style: style ?? textStyle),
      );
      text2Painter.layout(maxWidth: text2MaxWidth);
      text2Painter.paint(canvas, Offset(text2X, y));

      // Move down for next line
      y += text1Painter.height + 8;
    }

    void drawItemText(
        int no,
        String name,
        int qty,
        int price, {
          TextStyle? style,
        }) {
      // Define column X positions
      const double noX = 0;
      const double nameX = 50;
      const double qtyX = 300;
      const double priceX = 450;

      // Max width for each column
      const double noMaxWidth = 50;
      const double nameMaxWidth = 300;
      const double qtyMaxWidth = 200;
      const double priceWidth = 150;

      final noPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: no==0 ? "" : no.toString(), style: style ?? textStyle),
      );
      noPainter.layout(maxWidth: noMaxWidth);
      noPainter.paint(canvas, Offset(noX, y));

      final namePainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: name, style: style ?? textStyle),
      );
      namePainter.layout(maxWidth: nameMaxWidth);
      namePainter.paint(canvas, Offset(nameX, y));

      final qtyPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        text: TextSpan(text: no==0 ? "Total" :  "$qty x $price", style: style ?? textStyle),
      );
      qtyPainter.layout(maxWidth: qtyMaxWidth);
      qtyPainter.paint(canvas, Offset(qtyX, y));

      final amountPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        text: TextSpan(text: no==0 ? "$price" : "${qty*price}", style: style ?? textStyle),
      );
      amountPainter.layout(maxWidth: priceWidth);
      amountPainter.paint(canvas, Offset(priceX, y));

      // y += namePainter.height + 5;
      // drawText(
      //   "---------------------------------------------------------------------------",
      //   align: TextAlign.center,
      // );

      y += namePainter.height + 8;
    }

    // 🏪 Header
    drawText(shopName.toString(), style: boldStyle, align: TextAlign.center);
    drawText(phone.toString(), align: TextAlign.center);
    drawText(address.toString(), align: TextAlign.center);
    drawHeaderColumn("", "");
    drawHeaderColumn("Invoice No", ": ${voucher.sale_no}");
    drawHeaderColumn("Customer", ": ${voucher.customer}");
    drawHeaderColumn("Sale Staff", ": ${voucher.user}");
    drawHeaderColumn("Payment", ": ${voucher.payment}");
    drawHeaderColumn("Date", ": ${voucher.created_at}");

    drawText(
      "-------------------------------------------------------------------------------",
      align: TextAlign.left,
    );
    int itemNo = 1;
    int totalAmount = 0;
    for(final item in saleDetailModels){
      drawItemText(itemNo, item.product.toString() , item.quantity! , item.price!);
      totalAmount += item.quantity! * item.price!;
      itemNo += 1;
    }

    // drawText(
    //   "----------------------------------------",
    //   align: TextAlign.center,
    // );
    // drawText("Total : $total", style: boldStyle, align: TextAlign.right);

    drawText(
      "-------------------------------------------------------------------------------",
      align: TextAlign.left,
    );

    drawItemText(0, "", 0, totalAmount);

    drawText(
      "-------------------------------------------------------------------------------",
      align: TextAlign.left,
    );

    y += 20;
    drawText("Thank you for your purchase!", align: TextAlign.center);

    // 🖼️ Finalize image
    final picture = pictureRecorder.endRecording();
    final imgBytes = await picture.toImage(580, y.toInt() + 40);
    final byteData = await imgBytes.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Save PNG to file
  Future<void> savePng(Uint8List bytes) async {
    final path = await getPath();
    final file = File(path);
    await file.writeAsBytes(bytes);
  }

  Future<String> getPath() async {
    final filename = "${voucher.sale_no}_slip.png";
    if (Platform.isAndroid) {
      await _getPermission();
      final dir = Directory('/storage/emulated/0/Download');
      return "${dir.path}/$filename";
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return "${dir.path}/$filename";
    }
  }

  Future<void> _getPermission() async {
    var state = await Permission.storage.status;
    if (state != PermissionStatus.granted) {
      await Permission.storage.request();
    }
  }
}
