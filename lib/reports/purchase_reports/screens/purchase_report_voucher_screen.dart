import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../controller/purchase_report_controller.dart';

class PurchaseReportVoucherScreen extends StatelessWidget {
  PurchaseReportVoucherScreen({super.key});
  PurchaseReportController purchaseController = Get.put(PurchaseReportController());
  SupplierController supplierController = SupplierController();
  int? supplierId;
  String date = 'today';

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    purchaseController.getAllVouchers(date: daterangeCalculate('today'));
    supplierController.getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Report"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: customersBox(),
          ),
          datePicker(),
          const ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child:  Text("No.")),
                Expanded(flex:2 ,child: Text("InvNo")),
                Expanded(flex:2 ,child: Text("Amount")),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: Obx(() {
            return ListView.builder(
                itemCount: purchaseController.vouchers.length,
                itemBuilder: (context, index) {
                  var voucher = purchaseController.vouchers[index];
                  return reportListTile(index: index+1,voucher: voucher);
                });
          })),
          Obx((){
            // salesController.getTotal();
            return Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child:ListTile(
                title:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Total",style: TextStyle(color: Colors.white),),
                    Text(purchaseController.totalAmount.toString(),style: const TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget reportListTile({required int index,required PurchaseModel voucher}){
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(index.toString())),
          Expanded(flex: 2,child: Text(voucher.purchaseNo.toString())),
          Expanded(flex: 2, child: Text(voucher.total_price.toString())),
        ],
      ),
    );
  }

  Widget customersBox() {
    return Obx((){
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Supplier",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: ['All']+supplierController.suppliers.map((customer) => customer.name.toString()).toList(),
        onChanged: (value) {
          if(value!='All'){
            final supplier = supplierController.suppliers.firstWhere(
                  (supplier) => supplier.name == value,
            );
            supplierId = supplier.id;
          }else{
            supplierId = null;
          }
          purchaseController.getAllVouchers(
            supplierId: supplierId,
            date: date!='all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem: "All", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Customer",
            ),
          ),
        ),
      );
    });
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownMenu(
        initialSelection: "today",
        width: double.infinity,
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: "all", label: "All"),
          DropdownMenuEntry(value: "today", label: "Today"),
          DropdownMenuEntry(value: "yesterday", label: "Yesterday"),
          DropdownMenuEntry(value: "thismonth", label: "This month"),
          DropdownMenuEntry(value: "lastmonth", label: "Last month"),
          DropdownMenuEntry(value: "thisyear", label: "This year"),
          DropdownMenuEntry(value: "lastyear", label: "Last year"),
        ],
        onSelected: (value) {
          date = value!;
          purchaseController.getAllVouchers(
              supplierId: supplierId,
              date: value!='all' ? daterangeCalculate(date) : null
          );
        },
      ),
    );
  }

  Map daterangeCalculate(String selectedDate) {
    String startDate = "";
    String endDate = "";
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    if (selectedDate == "today") {
      startDate = today.toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "yesterday") {
      startDate = DateTime(now.year, now.month, now.day - 1).toString();
      endDate = DateTime(now.year, now.month, now.day).toString();
    } else if (selectedDate == "thismonth") {
      startDate = DateTime(now.year, now.month, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "lastmonth") {
      startDate = DateTime(now.year, now.month - 1, 1).toString();
      endDate = DateTime(now.year, now.month, 1).toString();
    } else if (selectedDate == "thisyear") {
      startDate = DateTime(now.year, 1, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "lastyear") {
      startDate = DateTime(now.year - 1, 1, 1).toString();
      endDate = DateTime(now.year, 1, 1).toString();
    }
    return {'start': startDate, 'end': endDate};
  }
}
