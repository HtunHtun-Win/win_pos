import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/screens/add_user_screen.dart';
import 'package:win_pos/user/screens/edit_user_screen.dart';

import '../models/user.dart';

// ignore: must_be_immutable
class UserScreen extends StatelessWidget {
  UserScreen({super.key});
  final UserController controller = Get.find();
  final List<String> roles = ['', 'admin', 'sale', 'purchase'];

  @override
  Widget build(BuildContext context) {
    controller.getAll();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const AddUserScreen());
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Obx(
        () {
          final users = controller.users;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: users.isEmpty
                ? Center(
                    child: Text(
                      'No users added yet.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _userCard(context, users[index], theme);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _userCard(BuildContext context, User user, ThemeData theme) {
    final bool isCurrentUser = controller.current_user['id'] == user.id;
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name.toString(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login: ${user.login_id}'),
            Text('Password: ${user.password}'),
            Text('Role: ${roles[user.role_id!]}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                controller.edit_user.value = user;
                Get.to(() => const EditUserScreen());
              },
              icon: const Icon(Icons.edit),
              color: theme.colorScheme.primary,
            ),
            IconButton(
              onPressed: isCurrentUser
                  ? null
                  : () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Delete User'),
                          content: const Text('This process can\'t be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.deleteUser(user.id!);
                                Get.back();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.delete),
              color: isCurrentUser
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                  : theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
