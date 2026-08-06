import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';

class ExpenseCategoryEditScreen extends StatefulWidget {
  ExpenseCategoryEditScreen({super.key});

  @override
  State<ExpenseCategoryEditScreen> createState() =>
      _ExpenseCategoryEditScreenState();
}

class _ExpenseCategoryEditScreenState extends State<ExpenseCategoryEditScreen> {
  final ExpenseController _expenseController = ExpenseController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController newValueController = TextEditingController();

  @override
  void dispose() {
    descController.dispose();
    newValueController.dispose();
    super.dispose();
  }

  Future<void> _renameCategory() async {
    if (newValueController.text.isEmpty) return;
    final int result = await _expenseController.updateDesc(
        descController.text, newValueController.text);
    if (result != 0) {
      Get.dialog(
        AlertDialog(
          title: const Text('Success!'),
          content: const Text('Expense category name successfully renamed.'),
          actions: [
            TextButton(
                onPressed: () {
                  descController.clear();
                  newValueController.clear();
                  Get.back();
                },
                child: const Text('OK'))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense Category'),
        actions: [
          IconButton(onPressed: _renameCategory, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Existing Category',
              controller: descController,
              hint: 'Search category',
              onChanged: (value) => _expenseController.getDescByKeyword(value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'New Category Name',
              controller: newValueController,
              hint: 'Enter new name',
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(
                () {
                  final searchList = _expenseController.searchList;
                  if (searchList.isEmpty) {
                    return Center(
                      child: Text(
                        'Search results will appear here.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: searchList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = searchList[index];
                      return _searchItem(context, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchItem(BuildContext context, String name) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        descController.text = name;
        _expenseController.searchList.value = [];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.category, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
