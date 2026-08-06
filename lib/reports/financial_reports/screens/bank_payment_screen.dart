import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/payment/controller/payment_controller.dart';
import 'package:win_pos/reports/financial_reports/controller/financial_report_controller.dart';

import '../../../sales/models/sale_model.dart';

// ignore: must_be_immutable
class BankPaymentScreen extends StatelessWidget {
  BankPaymentScreen({super.key});

  FinancialReportController controller = FinancialReportController();
  PaymentController paymentController = PaymentController();
  int? paymentId;
  String date = 'today';
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    controller.getBankPayment();
    paymentController.getAll();
    if(date != 'all'){
      controller.getBankPayment(date: daterangeCalculate(date));
    }else{
      controller.getBankPayment();
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Payment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Obx(() => paymentBox())),
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
                  if (controller.maxCount == controller.vouchers.length) {
                    refreshController.loadNoData();
                  } else {
                    controller.loadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.showVouchers.length,
                  itemBuilder: (context, index) {
                    var voucher = controller.showVouchers[index];
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
                  'Total: ${controller.totalAmount}',
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

  Widget reportListTile({required int index, required SaleModel voucher}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(index.toString())),
            Expanded(flex: 2, child: Text(voucher.sale_no.toString())),
            Expanded(flex: 2, child: Text(voucher.payment!)),
            Expanded(flex: 2, child: Text(voucher.total_price.toString())),
          ],
        ),
      ),
    );
  }

  Widget paymentBox() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Payment',
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: paymentController.payments.map((payment) {
        if (payment.name == 'Cash') return 'All';
        return payment.name.toString();
      }).toList(),
      onChanged: (value) {
        refreshController.loadFailed();
        if (value != 'All') {
          final payment = paymentController.payments.firstWhere(
            (payment) => payment.name == value,
          );
          paymentId = payment.id;
        } else {
          paymentId = null;
        }
        controller.getBankPayment(
          paymentId: paymentId,
          date: date != 'all' ? daterangeCalculate(date) : null,
        );
      },
      selectedItem: 'All',
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Payment',
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
        items: const ['All', 'Today', 'Yesterday', 'ThisMonth', 'LastMonth', 'ThisYear', 'LastYear'],
        onChanged: (value) {
          refreshController.loadFailed();
          date = value!.toLowerCase();
          controller.getBankPayment(
            paymentId: paymentId,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text('No.', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text('InvNo', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text('Payment', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text('Amount', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
