import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/screens/sales_screen.dart';
import 'package:win_pos/sales/screens/voucher_item.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import '../../core/functions/date_range_calc.dart';
import '../../shop/shop_info_controller.dart';

// ignore: must_be_immutable
class SalesVoucherScreen extends StatelessWidget {
  SalesVoucherScreen({super.key});

  SalesController salesController = Get.put(SalesController());
  ShopInfoController shopInfoController = Get.put(ShopInfoController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    if(salesController.selectedDate == 'all') {
      salesController.getAllVouchers();
    } else {
      salesController.getAllVouchers(map: daterangeCalculate(salesController.selectedDate));
    }
    
    shopInfoController.getAll();

    Future<bool> popAction() async {
      bool state = false;
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                "Are you sure to exit?",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    state = false;
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    state = true;
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          });
      return state;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        bool state = await popAction();
        if (state) {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sales Vouchers"),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer:
            CustDrawer(user: User.fromMap(controller.current_user.toJson())),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            datePicker(),
            Expanded(child: Obx(() {
              return SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                footer: CustomFooter(builder: (context, LoadStatus? mode) {
                  Widget body = Container();
                  if (mode == LoadStatus.loading) {
                    body = const CircularProgressIndicator();
                  } else if (mode == LoadStatus.noMore) {
                    body = const Text("No More Data...");
                  }
                  return SizedBox(
                    height: 55,
                    child: Center(
                      child: body,
                    ),
                  );
                }),
                onLoading: () {
                  if (salesController.maxCount ==
                      salesController.vouchers.length) {
                    refreshController.loadNoData();
                  } else {
                    salesController.loadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                    itemCount: salesController.showVouchers.length,
                    itemBuilder: (context, index) {
                      var voucher = salesController.showVouchers[index];
                      return VoucherItem(voucher: voucher);
                    }),
              );
            }))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            refreshController.loadFailed();
            Get.to(() => SalesScreen());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 10),
      child: DropdownMenu(
        initialSelection: salesController.selectedDate,
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
          salesController.selectedDate = value!;
          salesController.maxCount = 10;
          refreshController.loadFailed();
          if (value == 'all') {
            salesController.getAllVouchers();
          } else {
            salesController.getAllVouchers(map: daterangeCalculate(value));
          }
        },
      ),
    );
  }
}
