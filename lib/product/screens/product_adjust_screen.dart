import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/product/controller/product_log_controller.dart';
import 'package:jue_pos/product/models/product_log_model.dart';
import 'package:intl/intl.dart';

class ProductAdjustScreen extends StatelessWidget {
  ProductAdjustScreen({super.key});
  ProductLogController productLogController = ProductLogController();

  @override
  Widget build(BuildContext context) {
    productLogController.getAll();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          datePicker(),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: productLogController.logs.length,
                  itemBuilder: (context, index) {
                    var product_log = productLogController.logs[index];
                    return listItem(product_log);
                  },
                )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget listItem(ProductLogModel log) {
    DateTime date = DateTime.parse(log.date.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m:s a");
    var final_date = fdate.format(date);
    return Container(
      child: ListTile(
        title: Text(log.product.toString()),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${log.quantity.toString()} (${log.user.toString()})'),
            Text(final_date),
          ],
        ),
      ),
    );
  }

  Widget datePicker(){
    return Container(
      padding: EdgeInsets.only(top: 5,right: 10),
      child: DropdownMenu(
        initialSelection: "all",
        dropdownMenuEntries: [
          DropdownMenuEntry(value: "all", label: "All"),
          DropdownMenuEntry(value: "today", label: "Today"),
          DropdownMenuEntry(value: "yesterday", label: "Yesterday"),
          DropdownMenuEntry(value: "thismonth", label: "This month"),
          DropdownMenuEntry(value: "lastmonth", label: "Last month"),
          DropdownMenuEntry(value: "thisyear", label: "This year"),
          DropdownMenuEntry(value: "lastyear", label: "Last year"),
        ],
        onSelected: (value){
          if(value=='all'){
            productLogController.getAll();
          }else{
            productLogController.getAll(map: daterangeCalculate(value!));
          }
        },
      ),
    );
  }

  Future<dynamic> addDialog() async{
    return Get.defaultDialog(
      title: "Product Adjust",
      middleText: "Choose product to adjust",
      content: Column(
        children: [
          TextField(),

        ],
      ),
    );
  }

  Map daterangeCalculate(String selectedDate){
    String startDate = "";
    String endDate = "";
    var now = DateTime.now();
    var today = DateTime(now.year,now.month,now.day);
    if(selectedDate=="today"){
      startDate = today.toString();
      endDate = DateTime(now.year,now.month,now.day+1).toString();
    }
    else if(selectedDate=="yesterday"){
      startDate = DateTime(now.year,now.month,now.day-1).toString();
      endDate = DateTime(now.year,now.month,now.day).toString();
    }
    else if(selectedDate=="thismonth"){
      startDate = DateTime(now.year,now.month,1).toString();
      endDate = DateTime(now.year,now.month,now.day+1).toString();
    }
    else if(selectedDate=="lastmonth"){
      startDate = DateTime(now.year,now.month-1,1).toString();
      endDate = DateTime(now.year,now.month,1).toString();
    }
    else if(selectedDate=="thisyear"){
      startDate = DateTime(now.year,1,1).toString();
      endDate = DateTime(now.year,now.month,now.day+1).toString();
    }
    else if(selectedDate=="lastyear"){
      startDate = DateTime(now.year-1,1,1).toString();
      endDate = DateTime(now.year,1,1).toString();
    }
    return {
      'start' : startDate,
      'end' : endDate
    };
  }
}
