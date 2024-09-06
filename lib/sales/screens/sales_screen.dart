import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/models/cart_model.dart';
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
                  //show cart items
                  Obx((){
                    return ListView.builder(
                      itemCount: salesController.cart.length,
                      itemBuilder: (context,index){
                        var item = salesController.cart[index];
                        return selectedItem(item,index);
                      },
                    );
                  }),
                  //for search result
                  Obx((){
                    return salesController.products.isEmpty ? Container() : ListView.builder(
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
          salesController.addToCart(product);
          salesController.products.clear();
          salesController.getTotal();
          print(salesController.totalAmount);
        },
      ),
    );
  }

  Widget selectedItem(CartModel item,index){
    var total = item.product!.sale_price! * item.quantity!;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(onPressed: (_){
            quantityAlert(item,index);
          },icon: Icons.edit,),
          SlidableAction(
            onPressed: (_){
              salesController.cart.remove(item);
              salesController.getTotal();
            },
            icon: Icons.delete
          )
        ],
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.product!.name.toString()),
            Text(total.toString())
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${item.sprice}x${item.quantity}"),
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

  void quantityAlert(CartModel item,index){
    qtyController.text = item.quantity.toString();
    Get.defaultDialog(
      title: item.product!.name!,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: (){
              int qty = int.parse(qtyController.text);
              qty--;
              qtyController.text = qty.toString();
              if(qty>0) salesController.cart[index].quantity--;
              salesController.cart.refresh();
              salesController.getTotal();
            },
            icon: Icon(Icons.remove),
          ),
          Expanded(
            child: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            onChanged: (value){
              int quantity = int.parse(value)>0 ? int.parse(value) : 1;
              salesController.cart[index].quantity=quantity;
              salesController.cart.refresh();
              salesController.getTotal();
            },
            textAlign: TextAlign.center,
          )),
          IconButton(
            onPressed: (){
              int qty = int.parse(qtyController.text);
              qty++;
              qtyController.text = qty.toString();
              salesController.cart[index].quantity++;
              salesController.cart.refresh();
              salesController.getTotal();
            },
             icon: Icon(Icons.add),
          ),
        ],
      )
    );
  }
}
