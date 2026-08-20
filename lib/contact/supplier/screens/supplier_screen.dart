import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';
import 'package:win_pos/contact/supplier/screens/supplier_add_screen.dart';
import 'package:win_pos/contact/supplier/screens/supplier_edit_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final SupplierController supplierController = Get.put(SupplierController());
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
                      supplierController.searchByKeyWork(value);
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
                      '${supplierController.suppliers.length}',
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
    return Slidable(
      enabled: userController.current_user["role_id"] == 1 ? true : false,
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: (_) {
            refreshController.loadFailed();
            Get.to(() => SupplierEditScreen(supplier));
          },
          icon: Icons.edit,
          foregroundColor: color,
        ),
        SlidableAction(
          onPressed: (_) {
            Get.dialog(AlertDialog(
                title: const Text("Delete!"),
                content: const Text("Are you sure to delete!"),
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
          title: Text(supplier.name.toString(),style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Row(
            children: [
              Expanded(child: Text(supplier.phone.toString())),
              Expanded(
                child: Text(
                  supplier.address.toString(),
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
