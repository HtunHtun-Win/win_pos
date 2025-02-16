import 'package:get/get.dart';
import 'package:win_pos/shop/shop_info_services.dart';

class ShopInfoController extends GetxController{

  ShopInfoServices shopInfoServices = ShopInfoServices();
  var shop = {}.obs;

  Future<void> getAll() async{
    var datas =  await shopInfoServices.getAll();
    shop.value = datas;
  }

  Future<void> updateInfo(String name,String address,String phone) async{
    await shopInfoServices.updateInfo(name, address, phone);
  }

}