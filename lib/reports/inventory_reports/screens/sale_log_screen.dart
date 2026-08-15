import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/core/functions/pretty_date_format.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/reports/inventory_reports/controller/inventory_report_controller.dart';
import 'package:win_pos/reports/inventory_reports/models/sale_log_model.dart';

// ignore: must_be_immutable
class SaleLogScreen extends StatefulWidget {
  SaleLogScreen({super.key});

  @override
  State<SaleLogScreen> createState() => _SaleLogScreenState();
}

class _SaleLogScreenState extends State<SaleLogScreen> {
  InventoryReportController reportController =
      Get.put(InventoryReportController());
  ProductController productController = Get.put(ProductController());

  final refreshController = RefreshController();

  int? pId;
  String date = 'today';

  @override
  void initState() {
    super.initState();
    reportController.getSaleLog(date: daterangeCalculate('today'));
    productController.getAll();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Price History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Obx(() => productList())),
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
          const Divider(),
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
                  if (reportController.saleLog.length >=
                      reportController.maxCount) {
                    refreshController.loadNoData();
                  } else {
                    reportController.saleLogLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reportController.showSalelog.length,
                  itemBuilder: (context, index) {
                    var saleLog = reportController.showSalelog[index];
                    return reportListTile(saleLog: saleLog);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget reportListTile({required SaleLogModel saleLog}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(saleLog.name.toString())),
            Expanded(flex: 2, child: Text(saleLog.oldPrice.toString())),
            Expanded(flex: 2, child: Text(saleLog.newPrice.toString())),
            Expanded(
                flex: 2, child: Text(prettyDate(saleLog.createdAt.toString()))),
          ],
        ),
      ),
    );
  }

  Widget productList() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Product',
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: ['All'] +
          productController.products
              .map((product) => product.name.toString())
              .toList(),
      onChanged: (value) {
        refreshController.resetNoData();
        if (value != 'All') {
          final product = productController.products.firstWhere(
            (product) => product.name == value,
          );
          pId = product.id;
        } else {
          pId = null;
        }
        reportController.getSaleLog(
          pid: pId,
          date: date != 'all' ? daterangeCalculate(date) : null,
        );
      },
      selectedItem: 'All',
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Product',
          ),
        ),
      ),
    );
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
        items: dateOptionList,
        onChanged: (value) {
          refreshController.resetNoData();
          date = value!.toLowerCase();
          reportController.getSaleLog(
            pid: pId,
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

class _TableHeader extends StatelessWidget {
  const _TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 2,
            child: Text('Name',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Text('Old',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Text('New',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Text('Date',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
