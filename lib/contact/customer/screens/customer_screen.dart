import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/contact/customer/screens/customer_add_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

import 'customer_edit_screen.dart';

// ignore: must_be_immutable
class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});

  final CustomerController customerController = Get.put(CustomerController());
  final UserController userController = Get.find();
  final refreshController = RefreshController();
  String filterInput = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      refreshController.loadFailed();
                      filterInput = value;
                      customerController.searchByKeyWork(value);
                    },
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                margin: const EdgeInsets.only(right: 6),
                width: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Obx(() {
                    return Text(
                      '${customerController.customers.length}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              ),
            ],
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
    return Slidable(
      enabled: userController.current_user["role_id"] == 1 ? true : false,
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: customer.id == 1
              ? (_) {}
              : (_) {
                  refreshController.loadFailed();
                  Get.to(() => CustomerEditScreen(customer));
                },
          icon: Icons.edit,
          foregroundColor: color,
        ),
        SlidableAction(
          onPressed: customer.id == 1
              ? (_) {}
              : (_) {
                  Get.dialog(AlertDialog(
                      title: const Text("Delete!"),
                      content:
                          const Text("Are you sure to delete this contact!"),
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
                      ]));
                },
          icon: Icons.delete,
          foregroundColor: Colors.red,
        )
      ]),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 10,
              )
            ]),
        child: ListTile(
          title: Text(customer.name.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Row(
            children: [
              Expanded(child: Text(customer.phone.toString())),
              Expanded(
                child: Text(
                  customer.address.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
