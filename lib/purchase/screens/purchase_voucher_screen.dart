import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/purchase/controller/purchase_controller.dart';
import 'package:win_pos/purchase/screens/purchase_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import '../../core/functions/date_range_calc.dart';
import '../../shop/shop_info_controller.dart';
import 'pvoucher_item.dart';

// ignore: must_be_immutable
class PurchaseVoucherScreen extends StatelessWidget {
  PurchaseVoucherScreen({super.key});

  PurchaseController purchaseController = Get.put(PurchaseController());
  ShopInfoController shopInfoController = Get.put(ShopInfoController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    purchaseController.getAllVouchers(map: daterangeCalculate('today'));
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
          title: const Text("Purchase Vouchers"),
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
                  if (purchaseController.maxCount ==
                      purchaseController.vouchers.length) {
                    refreshController.loadNoData();
                  } else {
                    purchaseController.loadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                    itemCount: purchaseController.showVouchers.length,
                    itemBuilder: (context, index) {
                      var voucher = purchaseController.showVouchers[index];
                      return PVoucherItem(voucher: voucher);
                    }),
              );
            }))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            refreshController.loadFailed();
            Get.to(() => PurchaseScreen());
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
        initialSelection: purchaseController.selectedDate,
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
          purchaseController.selectedDate=value!;
          purchaseController.maxCount=10;
          refreshController.loadFailed();
          if (value == 'all') {
            purchaseController.getAllVouchers();
          } else {
            purchaseController.getAllVouchers(map: daterangeCalculate(value));
          }
        },
      ),
    );
  }
}
