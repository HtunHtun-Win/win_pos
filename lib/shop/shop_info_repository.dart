import 'package:jue_pos/core/database/db_helper.dart';

class ShopInfoRepository{
  DbHelper dbObj = DbHelper();

  Future<Map> getAll() async{
    final database = await dbObj.database;
    var data = await database.query("shop_info");
    return data[0];
  }

  Future<void> updateInfo(String name,String address,String phone) async{
    final database = await dbObj.database;
    await database.update(
      "shop_info",
      {
        "shop_name" : name,
        "shop_address" : address,
        "shop_phone" : phone,
      },
      where: "id=1"
    );
  }
}