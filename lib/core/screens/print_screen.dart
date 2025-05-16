import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:win_pos/core/service/pdf_service.dart';
import 'package:win_pos/core/widgets/custom_btn.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/shop/shop_model.dart';

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
  PdfPageFormat size = PdfPageFormat.a5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Row(
            children: [
              myRadio(label: "A4", value: PdfPageFormat.a4),
              myRadio(label: "A5", value: PdfPageFormat.a5),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomBtn(
                  fun: () async {
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
                    );
                  },
                  lable: "Save as PDF",
                ),
              ),
              Expanded(
                child: CustomBtn(
                  fun: () async {
                    PdfService pdfService = PdfService(
                      size: size,
                      shopModel: widget.shopModel,
                      voucher: widget.voucher,
                      saleDetailModels: widget.saleDetailModels,
                    );
                    var byteList = await pdfService.generatePdf();
                    await pdfService.printPdf(byteList);
                  },
                  lable: "Print",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget myRadio({var value, required String label}) {
    return InkWell(
      onTap: () {
        size = value!;
        setState(() {});
      },
      child: Row(
        children: [
          Radio(
            value: value,
            groupValue: size,
            onChanged: (value) {
              size = value!;
              setState(() {});
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}
