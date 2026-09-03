import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/payment/controller/payment_controller.dart';
import 'package:win_pos/reports/financial_reports/controller/financial_report_controller.dart';
import 'package:win_pos/sales/screens/sales_detail.dart';
import 'package:win_pos/shop/shop_info_controller.dart';

import '../../../sales/models/sale_model.dart';

// ignore: must_be_immutable
class BankPaymentScreen extends StatelessWidget {
  BankPaymentScreen({super.key});

  FinancialReportController controller = FinancialReportController();
  PaymentController paymentController = PaymentController();
  ShopInfoController shopInfoController = Get.find();
  int? paymentId;
  String date = 'today';
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    controller.getBankPayment();
    paymentController.getAll();
    shopInfoController.getAll();
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
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
            child: Row(
              children: [
                Expanded(child: Obx(() => paymentBox())),
                const SizedBox(width: 12),
                Expanded(child: datePicker()),
              ],
            ),
          ),
          const _TableHeader(),
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.showVouchers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    var voucher = controller.showVouchers[index];
                    return reportListTile(index: index + 1, voucher: voucher);
                  },
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                          () => Text(
                        "${controller.totalAmount} MMK",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reportListTile({required int index, required SaleModel voucher}) {
    return InkWell(
      onTap: () => Get.to(()=>SalesDetail(voucher: voucher)),
      child: Container(
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
        items: dateOptionList,
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
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text('No.', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('InvNo', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('Payment', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }
}
