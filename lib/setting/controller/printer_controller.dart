import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import 'package:image/image.dart' as img;
import 'package:win_pos/core/service/show_toast.dart';

class PrinterController extends GetxController {
  var state = PrinterState.initial().obs;

  void getDevices() async {
    // var status = await PrintBluetoothThermal.connectionStatus;
    state.value = state.value.copyWith(devices: [], isLoading: true);
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      state.value = PrinterState.success(devices);
    } catch (e) {
      state.value = state.value.copyWith();
    }
    loadPrinter();
  }

  void connect(BluetoothInfo info) async {
    bool? connected = await PrintBluetoothThermal.connectionStatus;
    if (connected == true) {
      await PrintBluetoothThermal.disconnect;
    }
    final ok =
        await PrintBluetoothThermal.connect(macPrinterAddress: info.macAdress);
    if (ok) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          "printer", jsonEncode({"name": info.name, "mac": info.macAdress}));
      state.value = state.value.copyWith(connectedMac: info);
      _showSnackBar(message: "Successfully connected.");
    } else {
      _showSnackBar(message: "Can't connect to printer.");
    }
  }

  void disconnect() async {
    await PrintBluetoothThermal.disconnect;
    state.value = state.value
        .copyWith(connectedMac: BluetoothInfo(name: "", macAdress: ""));
    _showSnackBar(message: "Printer is successfully disconnected");
  }

  void _showSnackBar({required String message}) {
    ShowToast.showNotiToast(msg: message);
  }

  void loadPrinter() async {
    state.value = state.value
        .copyWith(connectedMac: BluetoothInfo(name: "", macAdress: ""));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = await prefs.getString("printer");
    if (data != null) {
      Map<String, dynamic> printerData = jsonDecode(data);
      BluetoothInfo info = BluetoothInfo(
        name: printerData["name"],
        macAdress: printerData["mac"],
      );
      bool conState = await PrintBluetoothThermal.connectionStatus;
      if (conState) {
        dev.log("connected");
        state.value = state.value.copyWith(connectedMac: info);
      } else {
        connect(info);
      }
    }
  }

  void testPrint() async {
    bool? connected = await PrintBluetoothThermal.connectionStatus;
    if (connected == true) {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      //Convert image to printer data
      Uint8List pngBytes = await _generateBurmeseVoucher();
      final decoded = img.decodeImage(pngBytes);
      List<int> bytes = [];
      bytes += generator.image(decoded!);

      // Add paper feed + cutter command
      bytes += generator.feed(3); // Feed a few lines before cutting
      bytes += generator.cut(); // Auto cut
      await PrintBluetoothThermal.writeBytes(bytes);
    } else {
      _showSnackBar(message: "Select a printer");
    }
  }

  Future<Uint8List> _generateBurmeseVoucher() async {
    // Voucher layout text
    const shopName = "ရွှေနဂါး";
    const address = "လှိုင်သာယာ၊ ရန်ကုန်မြို့";
    const items = [
      {"name": "ပန်းသီး", "price": "3000 Ks"},
      {"name": "ငှက်ပျောသီး", "price": "2000 Ks"},
      {"name": "သစ်တော်သီး", "price": "2500 Ks"},
    ];
    const total = "7500 Ks";

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

    void drawRowText(
      String text,
      String qty,
      String price, {
      TextStyle? style,
    }) {
      // Define column X positions
      const double nameX = 0;
      const double qtyX = 350;
      const double priceX = 470;

      // Max width for each column
      const double nameMaxWidth = 340;
      const double qtyMaxWidth = 100;
      const double priceMaxWidth = 100;

      // Draw product name (left-aligned)
      final namePainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style ?? textStyle),
      );
      namePainter.layout(maxWidth: nameMaxWidth);
      namePainter.paint(canvas, Offset(nameX, y));

      // Draw quantity (center-aligned)
      final qtyPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(text: qty, style: style ?? textStyle),
      );
      qtyPainter.layout(maxWidth: qtyMaxWidth);
      qtyPainter.paint(canvas, Offset(qtyX, y));

      // Draw price (right-aligned)
      final pricePainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        text: TextSpan(text: price, style: style ?? textStyle),
      );
      pricePainter.layout(maxWidth: priceMaxWidth);
      pricePainter.paint(canvas, Offset(priceX, y));

      // Move down for next line
      y += namePainter.height + 8;
    }

    // 🏪 Header
    drawText(shopName, style: boldStyle, align: TextAlign.center);
    drawText(address, align: TextAlign.center);
    y += 10;
    drawText(
      "----------------------------------------",
      align: TextAlign.center,
    );

    for (final item in items) {
      drawRowText("${item['name']}", "5", "${item['price']}", style: textStyle);
    }

    y += 10;
    drawText(
      "----------------------------------------",
      align: TextAlign.center,
    );
    drawText("စုစုပေါင်း: $total", style: boldStyle, align: TextAlign.right);

    y += 20;
    drawText("ကျေးဇူးတင်ပါသည်။", align: TextAlign.center);

    // 🖼️ Finalize image
    final picture = pictureRecorder.endRecording();
    final imgBytes = await picture.toImage(580, y.toInt() + 40);
    final byteData = await imgBytes.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class PrinterState {
  final List<BluetoothInfo> devices;
  final bool isLoading;
  BluetoothInfo? connectedMac;
  PrintBluetoothThermal? printBluetoothThermal;

  PrinterState({
    required this.devices,
    required this.isLoading,
    this.connectedMac,
    this.printBluetoothThermal,
  });

  factory PrinterState.initial() => PrinterState(
        devices: [],
        isLoading: false,
        connectedMac: null,
        printBluetoothThermal: PrintBluetoothThermal(),
      );

  factory PrinterState.success(List<BluetoothInfo> devices) => PrinterState(
        devices: devices,
        isLoading: false,
      );

  PrinterState copyWith(
          {List<BluetoothInfo>? devices,
          bool? isLoading,
          BluetoothInfo? connectedMac,
          PrintBluetoothThermal? printBluetoothThermal}) =>
      PrinterState(
        devices: devices ?? this.devices,
        isLoading: isLoading ?? this.isLoading,
        connectedMac: connectedMac ?? this.connectedMac,
        printBluetoothThermal:
            printBluetoothThermal ?? this.printBluetoothThermal,
      );
}
