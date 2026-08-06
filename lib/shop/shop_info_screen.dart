import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/shop/shop_info_controller.dart';
import 'package:win_pos/shop/shop_model.dart';

class ShopInfoScreen extends StatefulWidget {
  ShopInfoScreen({super.key});

  @override
  State<ShopInfoScreen> createState() => _ShopInfoScreenState();
}

class _ShopInfoScreenState extends State<ShopInfoScreen> {
  final ShopInfoController shopInfoController = Get.put(ShopInfoController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    shopInfoController.getAll();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _populateFields(Map shopData) {
    if (!_hasLoaded && shopData.isNotEmpty) {
      final shopModel = ShopModel.fromMap(shopData);
      nameController.text = shopModel.name ?? '';
      addressController.text = shopModel.address ?? '';
      phoneController.text = shopModel.phone ?? '';
      _hasLoaded = true;
    }
  }

  Future<void> _saveInfo() async {
    await shopInfoController.updateInfo(
      nameController.text.trim(),
      addressController.text.trim(),
      phoneController.text.trim(),
    );
    Get.dialog(
      AlertDialog(
        title: const Text('Success'),
        content: const Text('Shop info successfully updated.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Info'),
      ),
      body: Obx(() {
        _populateFields(shopInfoController.shop);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildInputField('Shop Name', nameController, theme),
                    const SizedBox(height: 16),
                    _buildInputField('Phone', phoneController, theme, type: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildInputField('Address', addressController, theme, maxLines: 4),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveInfo,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Update Shop Info'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, ThemeData theme,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: 'Enter $label',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
