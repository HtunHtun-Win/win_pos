import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:win_pos/core/service/pdf_service.dart';
import 'package:win_pos/core/service/png_voucher_service.dart';
import 'package:win_pos/core/service/show_toast.dart';
import 'package:win_pos/core/widgets/custom_btn.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/setting/controller/printer_controller.dart';
import 'package:win_pos/setting/printer_select_screen.dart';
import 'package:win_pos/shop/shop_model.dart';
import 'package:image/image.dart' as img;

class PrintScreen extends StatefulWidget {
  const PrintScreen({
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
    super.initState();
    printerController.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Paper size',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child:
                                sizeBtn(label: 'A4', value: PdfPageFormat.a4)),
                        const SizedBox(width: 10),
                        Expanded(
                            child:
                                sizeBtn(label: 'A5', value: PdfPageFormat.a5)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: sizeBtn(
                                label: '80mm', value: PdfPageFormat.roll80)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Obx(
                  () {
                    final connected =
                        printerController.state.value.connectedMac;
                    return Row(
                      children: [
                        const Icon(Icons.usb, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            connected != null
                                ? 'Connected device: ${connected.name}'
                                : 'No printer connected',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomBtn(
                    bgColor: size == PdfPageFormat.roll80 ? Colors.grey : null,
                    fun: size == PdfPageFormat.roll80
                        ? () {}
                        : () async {
                            PdfService pdfService = PdfService(
                              size: size,
                              shopModel: widget.shopModel,
                              voucher: widget.voucher,
                              saleDetailModels: widget.saleDetailModels,
                            );
                            var byteList = await pdfService.generatePdf();
                            await pdfService.savePdf(byteList);
                            ShowToast.showNotiToast(msg: "File was saved successfully in download folder.");
                          },
                    lable: 'Save as PDF',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomBtn(
                    fun: () async {
                      return isSlip ? printPng() : printPdf();
                    },
                    lable: 'Print',
                  ),
                ),
              ],
            ),
            if (pngBytes != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.memory(pngBytes!, fit: BoxFit.contain),
                ),
              ),
            ]
          ],
        ),
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
