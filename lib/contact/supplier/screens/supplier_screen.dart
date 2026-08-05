import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';
import 'package:win_pos/contact/supplier/screens/supplier_add_screen.dart';
import 'package:win_pos/contact/supplier/screens/supplier_edit_screen.dart';

class SupplierScreen extends StatelessWidget {
  SupplierScreen({super.key});

  final SupplierController supplierController = Get.put(SupplierController());
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
                supplierController.searchByKeyWork(value);
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
                    if (supplierController.maxCount ==
                        supplierController.suppliers.length) {
                      refreshController.loadNoData();
                    } else {
                      supplierController.loadMore();
                      refreshController.loadComplete();
                    }
                  },
                  child: ListView.builder(
                    itemCount: supplierController.showSuppliers.length,
                    itemBuilder: (context, index) {
                      var supplier = supplierController.showSuppliers[index];
                      if (supplier.id == 1) {
                        return Container();
                      }
                      return listItem(context, supplier);
                    },
                  ),
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshController.loadFailed();
          Get.to(() => SupplierAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(context, SupplierModel supplier) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: ListTile(
          title: Text(supplier.name.toString()),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(supplier.phone.toString()),
              Expanded(
                child: Text(
                  supplier.address.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: supplier.id == 1
              ? const SizedBox()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          refreshController.loadFailed();
                          Get.to(() => SupplierEditScreen(supplier));
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
                                    supplierController.delete(supplier.id!);
                                    supplierController.searchByKeyWork(filterInput);
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
