import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';
import '../controller/purchase_report_controller.dart';

// ignore: must_be_immutable
class PurchaseReportVoucherScreen extends StatelessWidget {
  PurchaseReportVoucherScreen({super.key});

  PurchaseReportController purchaseController =
      Get.put(PurchaseReportController());
  SupplierController supplierController = SupplierController();
  int? supplierId;
  String date = 'today';
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    purchaseController.getAllVouchers(date: daterangeCalculate('today'));
    supplierController.getAll();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: customersBox()),
                const SizedBox(width: 12),
                Expanded(child: datePicker()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _TableHeader(),
          ),
          Expanded(
            child: Obx(() {
              return SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                footer: CustomFooter(builder: (context, LoadStatus? mode) {
                  Widget body = Container();
                  if (mode == LoadStatus.loading) {
                    body = const CircularProgressIndicator();
                  } else if (mode == LoadStatus.noMore) {
                    body = const Text('No More Data...');
                  }
                  return SizedBox(
                    height: 55,
                    child: Center(child: body),
                  );
                }),
                onLoading: () {
                  if (purchaseController.maxCount ==
                      purchaseController.vouchers.length) {
                    refreshController.loadNoData();
                  } else {
                    purchaseController.voucherLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: purchaseController.showVouchers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    var voucher = purchaseController.showVouchers[index];
                    return reportListTile(index: index + 1, voucher: voucher);
                  },
                ),
              );
            }),
          ),
          Obx(() {
            return Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  'Total: ${purchaseController.totalAmount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget reportListTile({required int index, required PurchaseModel voucher}) {
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
              child: Text(voucher.purchaseNo.toString()),
            ),
            Expanded(
              flex: 2,
              child: Text(
                voucher.total_price.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customersBox() {
    return Obx(() {
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Supplier',
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: ['All'] +
            supplierController.suppliers
                .map((customer) => customer.name.toString())
                .toList(),
        onChanged: (value) {
          refreshController.loadFailed();
          if (value != 'All') {
            final supplier = supplierController.suppliers.firstWhere(
              (supplier) => supplier.name == value,
            );
            supplierId = supplier.id;
          } else {
            supplierId = null;
          }
          purchaseController.getAllVouchers(
            supplierId: supplierId,
            date: date != 'all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem: 'All',
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Supplier',
            ),
          ),
        ),
      );
    });
  }

  Widget datePicker() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: const [
          'All',
          'Today',
          'Yesterday',
          'ThisMonth',
          'LastMonth',
          'ThisYear',
          'LastYear',
        ],
        onChanged: (value) {
          refreshController.loadFailed();
          date = value!.toLowerCase();
          purchaseController.getAllVouchers(
            supplierId: supplierId,
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

  Map<String, String> daterangeCalculate(String selectedDate) {
    String startDate = '';
    String endDate = '';
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    if (selectedDate == 'today') {
      startDate = today.toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'yesterday') {
      startDate = DateTime(now.year, now.month, now.day - 1).toString();
      endDate = DateTime(now.year, now.month, now.day).toString();
    } else if (selectedDate == 'thismonth') {
      startDate = DateTime(now.year, now.month, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'lastmonth') {
      startDate = DateTime(now.year, now.month - 1, 1).toString();
      endDate = DateTime(now.year, now.month, 1).toString();
    } else if (selectedDate == 'thisyear') {
      startDate = DateTime(now.year, 1, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'lastyear') {
      startDate = DateTime(now.year - 1, 1, 1).toString();
      endDate = DateTime(now.year, 1, 1).toString();
    }
    return {'start': startDate, 'end': endDate};
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('No.', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Inv No', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Amount', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
