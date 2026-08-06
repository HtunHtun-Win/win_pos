import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/category/models/category_model.dart';
import 'package:win_pos/category/screens/category_add_screen.dart';
import 'package:win_pos/category/screens/category_edit_screen.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => CategoryAddScreen()),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Obx(() {
        final items = categoryController.categories.where((c) => c.id != 1).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'No categories available.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _categoryTile(context, items[index]);
                  },
                ),
        );
      }),
    );
  }

  Widget _categoryTile(BuildContext context, CategoryModel category) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: Text(
          category.name.toString(),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(category.description.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => CategoryEditScreen(category));
              },
              icon: const Icon(Icons.edit),
              color: theme.colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete'),
                    content: const Text('Are you sure you want to delete this category?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          categoryController.deleteCategory(category.id!);
                          Get.back();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
