import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jue_pos/shop/shop_info_controller.dart';
import 'package:jue_pos/shop/shop_model.dart';

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
          title: Text('Shop'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx((){
        if(shopInfoController.shop.isNotEmpty){
          ShopModel shopModel = ShopModel.fromMap(shopInfoController.shop);
          nameController.text = shopModel.name!;
          addressController.text = shopModel.address!;
          phoneController.text = shopModel.phone!;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            inputField("Name",nameController),
            inputField("Address",addressController),
            inputField("Phone",phoneController),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child:TextButton(onPressed: (){
                shopInfoController.updateInfo(
                    nameController.text,
                    addressController.text,
                    phoneController.text
                );
              }, child: Text("Update")),
            )
          ],
        );
      }),
    );
  }

  Widget inputField(title,controller){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18
            ),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder()
            ),
          )
        ],
      ),
    );
  }
}
