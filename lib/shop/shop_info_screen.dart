import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:win_pos/shop/shop_info_controller.dart';
import 'package:win_pos/shop/shop_model.dart';

class ShopInfoScreen extends StatelessWidget {
  ShopInfoScreen({super.key});
  ShopInfoController shopInfoController = ShopInfoController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    shopInfoController.getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(() {
        if (shopInfoController.shop.isNotEmpty) {
          ShopModel shopModel = ShopModel.fromMap(shopInfoController.shop);
          nameController.text = shopModel.name!;
          addressController.text = shopModel.address!;
          phoneController.text = shopModel.phone!;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            inputField("Name", nameController),
            inputField("Phone", phoneController,type: TextInputType.number),
            inputField("Address", addressController,maxLine: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                  onPressed: () async{
                    await shopInfoController.updateInfo(nameController.text,
                        addressController.text, phoneController.text);
                    Get.snackbar("Success!", "Update Success!");
                  },
                  child: const Text("Update"),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget inputField(title, controller,{maxLine,type}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          TextField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLine,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          )
        ],
      ),
    );
  }
}
