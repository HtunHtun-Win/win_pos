import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:win_pos/core/widgets/custom_btn.dart';
import 'package:win_pos/purchase/models/purchase_detail_model.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import '../shop/shop_model.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({
    super.key,
    required this.pdfData,
    required this.shopModel,
    this.saleModel,
    this.purchaseModel,
    this.saleItemList,
    this.purchaseItemList,
  });
  @override
  _PrintScreenState createState() => _PrintScreenState();
  final Uint8List pdfData;
  final ShopModel shopModel;
  final SaleModel? saleModel;
  final PurchaseModel? purchaseModel;
  final List<SaleDetailModel>? saleItemList;
  final List<PurchaseDetailModel>? purchaseItemList;
}

class _PrintScreenState extends State<PrintScreen> {
  BlueThermalPrinter bluetoothPrinter = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  void _initBluetooth() async {
    devices = await bluetoothPrinter.getBondedDevices();
    setState(() {});
  }

  Future<void> _print() async {
    bool? isConnected = await bluetoothPrinter.isConnected;
    if(isConnected ?? false){
      if(widget.saleModel != null){
        _printSales();
      }else{
        _printPurchase();
      }
    }else{
      Get.snackbar(
          "Disconnected...",
          "Please connect with printer..."
      );
    }
  }

  Future<void> _printSales() async {
    DateTime date = DateTime.parse(widget.saleModel!.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.print3Column("", widget.shopModel.name!, "", 80);
    bluetoothPrinter.print3Column("", widget.shopModel.phone!, "", 80);
    bluetoothPrinter.print3Column("", widget.shopModel.address!, "", 80);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.print3Column("INV No.", ":", widget.saleModel!.sale_no!, 80);
    bluetoothPrinter.print3Column("Customer", ":", widget.saleModel!.customer!, 80);
    bluetoothPrinter.print3Column("Sale Staff", ":", widget.saleModel!.user!, 80);
    bluetoothPrinter.print3Column("Payment", ":", widget.saleModel!.payment!, 80);
    bluetoothPrinter.print3Column("Date", ":", finalDate, 80);
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("No","Name","Price","Amount", 80);
    for(var i=0;i<widget.saleItemList!.length;i++){
      var item = widget.saleItemList![i];
      bluetoothPrinter.print4Column("${i+1}",item.product!,"${item.price} x ${item.quantity}","${item.price!*item.quantity!}", 80);
    }
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("","","Net Price",widget.saleModel!.net_price.toString(), 80);
    if(widget.saleModel!.discount!=0) {
      bluetoothPrinter.print4Column(
          "", "", "Discount", widget.saleModel!.discount.toString(), 80);
    }
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("","","Total",widget.saleModel!.total_price.toString(), 80);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.paperCut();
  }

  Future<void> _printPurchase() async {
    DateTime date = DateTime.parse(widget.purchaseModel!.created_at.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m a");
    var finalDate = fdate.format(date);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.print3Column("", widget.shopModel.name!, "", 80);
    bluetoothPrinter.print3Column("", widget.shopModel.phone!, "", 80);
    bluetoothPrinter.print3Column("", widget.shopModel.address!, "", 80);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.print3Column("INV No.", ":", widget.purchaseModel!.purchaseNo!, 80);
    bluetoothPrinter.print3Column("Customer", ":", widget.purchaseModel!.supplier!, 80);
    bluetoothPrinter.print3Column("Sale Staff", ":", widget.purchaseModel!.user!, 80);
    bluetoothPrinter.print3Column("Payment", ":", widget.purchaseModel!.payment!, 80);
    bluetoothPrinter.print3Column("Date", ":", finalDate, 80);
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("No","Name","Price","Amount", 80);
    for(var i=0;i<widget.purchaseItemList!.length;i++){
      var item = widget.purchaseItemList![i];
      bluetoothPrinter.print4Column("${i+1}",item.product!,"${item.price} x ${item.quantity}","${item.price!*item.quantity!}", 80);
    }
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("","","Net Price",widget.purchaseModel!.net_price.toString(), 80);
    if(widget.purchaseModel!.discount!=0) {
      bluetoothPrinter.print4Column(
          "", "", "Discount", widget.purchaseModel!.discount.toString(), 80);
    }
    bluetoothPrinter.printLeftRight("-----", "-----", 80);
    bluetoothPrinter.print4Column("","","Total",widget.purchaseModel!.total_price.toString(), 80);
    bluetoothPrinter.printNewLine();
    bluetoothPrinter.paperCut();
  }

  Future<void> _savePdf() async {
    Uint8List pdfBytes = widget.pdfData;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  void _connect(device) async{
    bool? isConnected = await bluetoothPrinter.isConnected;
    try{
      if(!isConnected!){
        Get.snackbar(
            "Connecting...",
            "Wait a few second..."
        );
        await bluetoothPrinter.connect(device);
        setState(() {
          selectedDevice = device;
        });
      }
    }catch(e){
      Get.snackbar(
        "Error",
        "Connection error!"
      );
    }
  }

  void _disconnect() async{
    bool? isConnected = await bluetoothPrinter.isConnected;
    if(isConnected! ?? false){
      await bluetoothPrinter.disconnect();
      setState(() {
        selectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: (){
                _disconnect();
              },
              icon: const Icon(Icons.bluetooth_disabled,color: Colors.white)
          )
        ],
      ),
      body: Column(
        children: [
          Column(
            children: devices.map((device){
              var bgColor = Colors.blueAccent;
              var textColor = Colors.white;
              if(selectedDevice ==  device){
                bgColor = Colors.yellowAccent;
                textColor = Colors.blueAccent;
              }
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                color: bgColor,
                child: ListTile(
                  textColor: textColor,
                  title: Text(device.name!),
                  onTap: () {
                    setState((){
                      _connect(device);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          // DropdownButton<BluetoothDevice>(
          //   hint: const Text("Select Printer"),
          //   value: selectedDevice,
          //   items: devices
          //       .map((device) => DropdownMenuItem(
          //     value: device,
          //     child: Text(device.name!),
          //   ))
          //       .toList(),
          //   onChanged: (device) => setState(() {
          //     selectedDevice = device;
          //     _connect();
          //   }),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: CustomBtn(fun: _savePdf, lable: "Save as pdf")),
              Expanded(child: CustomBtn(fun: _print, lable: "Print")),
            ],
          )
        ],
      ),
    );
  }
}
