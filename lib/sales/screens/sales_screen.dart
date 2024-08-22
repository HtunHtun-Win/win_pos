import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/screens/sales_save_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class SalesScreen extends StatelessWidget {
  SalesScreen({super.key});
  SalesController salesController = Get.put(SalesController());
  TextEditingController searchController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: (){
                Get.to(()=>SalesSaveScreen());
              },
              icon: Icon(Icons.save)
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            userInput(),
            Expanded(
              child: Stack(
                children: [
                  Obx((){
                    return ListView.builder(
                      itemCount: salesController.selectedProduct.length,
                      itemBuilder: (context,index){
                        var product = salesController.selectedProduct[index];
                        return selectedItem(product);
                      },
                    );
                  }),
                  Obx((){
                    return salesController.products.length==0 ? Container() : ListView.builder(
                      itemCount: salesController.products.length,
                      itemBuilder: (context,index){
                        var product = salesController.products[index];
                        return searchItem(context,product);
                      },
                    );
                  }),
                ],
              ),
            ),
            Obx((){
              return totalAmountWidget(context, salesController.totalAmount);
            })
          ]
        ),
      ),
    );
  }

  Widget userInput(){
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search...",
            ),
            onChanged: (value){
              salesController.getAllProduct(input: value);
            },
          ),
        ),
        IconButton(
            onPressed: (){
              searchController.text = "";
            },
            icon: Icon(Icons.cancel)
        )
      ],
    );
  }

  Widget searchItem(context,ProductModel product){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: Offset(5,5),
            blurRadius: 10
          )
        ]
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name.toString()),
            Text(product.sale_price.toString())
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.code.toString()),
            Text(product.quantity.toString())
          ],
        ),
        onTap: (){
          salesController.totalAmount.value = 0;
          if(salesController.cart.value["${product.id}"]!=null){
            salesController.cart.value["${product.id}"] += 1;
          }else{
            salesController.cart.value["${product.id}"] = 1;
          }
          salesController.addToSelectedProduct();
          salesController.products.clear();
        },
      ),
    );
  }

  Widget selectedItem(ProductModel product){
    var total = product.sale_price! * salesController.cart[product.id.toString()] as int;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(onPressed: (_){
            quantityAlert(product);
          },icon: Icons.edit,),
          SlidableAction(
            onPressed: (_){
              salesController.totalAmount.value = 0;
              salesController.cart.remove(product.id.toString());
              salesController.addToSelectedProduct();
            },
            icon: Icons.delete
          )
        ],
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name.toString()),
            Text(total.toString())
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${product.sale_price}x${salesController.cart[product.id.toString()]}"),
          ],
        ),
      ),
    );
  }

  Widget totalAmountWidget(context,amount){
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.inversePrimary,
      child: ListTile(
        title: Text("Total : $amount"),
      ),
    );
  }

  void quantityAlert(ProductModel product){
    qtyController.text = salesController.cart[product.id.toString()].toString();
    Get.defaultDialog(
      title: product.name!,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: (){
              int qty = int.parse(qtyController.text);
              qty--;
              qtyController.text = qty.toString();
              salesController.cart[product.id.toString()]--;
              salesController.totalAmount.value = 0;
              salesController.addToSelectedProduct();
            },
            icon: Icon(Icons.remove),
          ),
          Expanded(
            child: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            onChanged: (value){
              salesController.cart[product.id.toString()]=int.parse(value);
              salesController.totalAmount.value = 0;
              salesController.addToSelectedProduct();
            },
            textAlign: TextAlign.center,
          )),
          IconButton(
            onPressed: (){
              int qty = int.parse(qtyController.text);
              qty++;
              qtyController.text = qty.toString();
              salesController.cart[product.id.toString()]++;
              salesController.totalAmount.value = 0;
              salesController.addToSelectedProduct();
            },
             icon: Icon(Icons.add),
          ),
        ],
      )
    );
  }
}
