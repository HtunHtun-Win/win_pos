import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/contact/customer/screens/customer_add_screen.dart';

import 'customer_edit_screen.dart';

// ignore: must_be_immutable
class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});

  final CustomerController customerController = Get.put(CustomerController());
  final refreshController = RefreshController();
  String filterInput = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                refreshController.loadFailed();
                filterInput = value;
                customerController.searchByKeyWork(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() => SmartRefresher(
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
                    if (customerController.maxCount ==
                        customerController.customers.length) {
                      refreshController.loadNoData();
                    } else {
                      customerController.loadMore();
                      refreshController.loadComplete();
                    }
                  },
                  child: ListView.builder(
                    itemCount: customerController.showCustomers.length,
                    itemBuilder: (context, index) {
                      var customer = customerController.showCustomers[index];
                      if (customer.id == 1) {
                        return Container();
                      }
                      return listItem(context, customer);
                    },
                  ),
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshController.loadFailed();
          Get.to(() => CustomerAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(context, CustomerModel customer) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: ListTile(
          title: Text(customer.name.toString()),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer.phone.toString()),
              Expanded(
                child: Text(
                  customer.address.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: customer.id == 1
              ? const SizedBox()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          refreshController.loadFailed();
                          Get.to(() => CustomerEditScreen(customer));
                        },
                        icon: Icon(
                          Icons.edit,
                          color: color,
                        )),
                    IconButton(
                        onPressed: () {
                          Get.defaultDialog(
                              title: "Delete!",
                              middleText: "Are you sure to delete!",
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    refreshController.loadFailed();
                                    customerController.delete(customer.id!);
                                    customerController.searchByKeyWork(filterInput);
                                    Get.back();
                                  },
                                  child: const Text("Ok"),
                                ),
                              ]);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: color,
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}
