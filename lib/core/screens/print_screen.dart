import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:win_pos/core/service/pdf_service.dart';
import 'package:win_pos/core/service/png_voucher_service.dart';
import 'package:win_pos/core/widgets/custom_btn.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/setting/controller/printer_controller.dart';
import 'package:win_pos/setting/printer_select_screen.dart';
import 'package:win_pos/shop/shop_model.dart';
import 'package:image/image.dart' as img;

class PrintScreen extends StatefulWidget {
  PrintScreen({
    super.key,
    required this.shopModel,
    required this.voucher,
    required this.saleDetailModels,
  });

  final ShopModel shopModel;
  final SaleModel voucher;
  final List<SaleDetailModel> saleDetailModels;

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  PrinterController printerController = Get.find<PrinterController>();
  PdfPageFormat size = PdfPageFormat.a5;
  bool isSlip = false;
  Uint8List? pngBytes;
  String? currentPrinter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    printerController.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              spacing: 10,
              children: [
                Expanded(child: sizeBtn(label: "A4", value: PdfPageFormat.a4)),
                Expanded(child: sizeBtn(label: "A5", value: PdfPageFormat.a5)),
                Expanded(
                    child: sizeBtn(label: "80mm", value: PdfPageFormat.roll80)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => Center(
                child: Text(printerController.state.value.connectedMac != null
                    ? "Connected Device : ${printerController.state.value.connectedMac!.name}"
                    : ""),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CustomBtn(
                  bgColor: size==PdfPageFormat.roll80 ? Colors.grey : null,
                  fun: size==PdfPageFormat.roll80 ? (){} :  () async {
                    PdfService pdfService = PdfService(
                      size: size,
                      shopModel: widget.shopModel,
                      voucher: widget.voucher,
                      saleDetailModels: widget.saleDetailModels,
                    );
                    var byteList = await pdfService.generatePdf();
                    await pdfService.savePdf(byteList);
                    Get.snackbar(
                      "Success",
                      "PDF file was saved in download folder!",
                      colorText: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      duration: const Duration(seconds: 1),
                    );
                  },
                  lable: "Save as PDF",
                ),
              ),
              Expanded(
                child: CustomBtn(
                  fun: () async {
                    return isSlip ? printPng() : printPdf();
                  },
                  lable: "Print",
                ),
              ),
            ],
          ),
          pngBytes == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.memory(pngBytes!, fit: BoxFit.contain))
        ],
      ),
    );
  }

  void printPdf() async {
    PdfService pdfService = PdfService(
      size: size,
      shopModel: widget.shopModel,
      voucher: widget.voucher,
      saleDetailModels: widget.saleDetailModels,
    );
    var byteList = await pdfService.generatePdf();
    await pdfService.printPdf(byteList);
  }

  void printPng() async {
    PngVoucherService pngService = PngVoucherService(
      shopModel: widget.shopModel,
      voucher: widget.voucher,
      saleDetailModels: widget.saleDetailModels,
    );
    var byteList = await pngService.generatePng();

    //print
    // setState(() {
    //   pngBytes = byteList;
    // });
    bool conState = await PrintBluetoothThermal.connectionStatus;
    if (conState) {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      //Convert image to printer data
      final decoded = img.decodeImage(byteList);
      List<int> bytes = [];
      bytes += generator.image(decoded!);

      // Add paper feed + cutter command
      bytes += generator.feed(3); // Feed a few lines before cutting
      bytes += generator.cut(); // Auto cut
      await PrintBluetoothThermal.writeBytes(bytes);
    } else {
      Get.to(const PrinterSelectScreen());
    }
  }

  Widget sizeBtn({var value, required String label}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: size == value ? Colors.blueGrey : Colors.blue,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        if (value == PdfPageFormat.roll80) {
          isSlip = true;
          size = PdfPageFormat.roll80;
        } else {
          isSlip = false;
          size = value!;
        }
        setState(() {});
      },
      child: Text(label),
    );
  }
}
