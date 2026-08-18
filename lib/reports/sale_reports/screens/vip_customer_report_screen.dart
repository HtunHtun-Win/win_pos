import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/reports/sale_reports/models/vip_customer_model.dart';
import '../controller/sales_report_controller.dart';

// ignore: must_be_immutable
class VipCustomerReportScreen extends StatelessWidget {
  VipCustomerReportScreen({super.key});

  final SalesReportController salesController =
      Get.put(SalesReportController());
  String date = 'today';

  @override
  Widget build(BuildContext context) {
    salesController.getVipCustomer(date: daterangeCalculate(date));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vip Customer Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Expanded(child: datePicker()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('No.',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: salesController.vipList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final voucher = salesController.vipList[index];
                  return reportListTile(index: index + 1, model: voucher);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget reportListTile({required int index, required VipCustomerModel model}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                index.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(model.name.toString()),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${model.total} MMK",
                // textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget datePicker() {
    List<String> dateOption = dateOptionList.where((e) => e != "All").toList();
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: dateOption,
        onChanged: (value) {
          date = value!.toLowerCase();
          salesController.getVipCustomer(
            date: date != 'all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem: 'Today',
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }
}
