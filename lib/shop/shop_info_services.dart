import 'package:win_pos/shop/shop_info_repository.dart';

class ShopInfoServices {
  ShopInfoRepository shopInfoRepository = ShopInfoRepository();

  Future<Map> getAll() async {
    return await shopInfoRepository.getAll();
  }

  Future<void> updateInfo(String name, String address, String phone) async {
    if (name.isNotEmpty) {
      await shopInfoRepository.updateInfo(name, address, phone);
    }
  }
}
