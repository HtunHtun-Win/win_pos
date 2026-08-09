import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:win_pos/core/functions/pretty_date_format.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';

class ExpenseAddScreen extends StatefulWidget {
  const ExpenseAddScreen({super.key});

  @override
  State<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen> {
  final ExpenseController _expenseController = Get.find();
  final TextEditingController amountController = TextEditingController(text: '0');
  final TextEditingController descController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  int flowType = 2;

  @override
  void initState() {
    super.initState();
    _expenseController.setDateTime(DateTime.now().toString());
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            onPressed: () => _saveExpense(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expense details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _buildDateRow(context),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Amount',
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    controller: descController,
                    onChanged: (value) => _expenseController.getDescByKeyword(value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Note (optional)',
                    controller: noteController,
                  ),
                  const SizedBox(height: 16),
                  _buildFlowDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildActionButtons(context),
            Obx(() => _buildSuggestionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionList() {
    final list = _expenseController.searchList;
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text('Suggestions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final name = list[index];
            return _searchItem(context, name);
          },
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prettyDate(_expenseController.dateTime.value),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextButton(
            onPressed: () async {
              final dateTime = await showOmniDateTimePicker(context: context);
              if (dateTime != null) {
                _expenseController.setDateTime(dateTime.toString());
              }
            },
            child: const Text('Select Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFlowDropdown() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Type',
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      ),
      items: const ['Expense', 'Income'],
      selectedItem: flowType == 2 ? 'Expense' : 'Income',
      onChanged: (value) {
        setState(() {
          flowType = value == 'Expense' ? 2 : 1;
        });
      },
      popupProps: const PopupProps.menu(showSearchBox: false),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.65)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Clear'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Save Expense'),
          ),
        ),
      ],
    );
  }

  void _resetForm() {
    amountController.text = '0';
    descController.clear();
    noteController.clear();
    setState(() {
      flowType = 2;
    });
  }

  Future<void> _saveExpense() async {
    final model = ExpenseModel(
      id: 0,
      amount: int.tryParse(amountController.text) ?? 0,
      description: descController.text,
      note: noteController.text,
      type: flowType,
      userId: 1,
      createdDate: _expenseController.dateTime.value,
    );

    final result = await _expenseController.addExpense(model);
    if (result['msg'] == 'null') {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing value'),
          content: const Text('Amount and description cannot be empty.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } else if (result['msg'] == 'success') {
      Get.back();
    }
  }
}
