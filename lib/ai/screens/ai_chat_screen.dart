import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/ai/controllers/ai_chat_controller.dart';
import 'package:win_pos/ai/models/ai_chat_message.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final UserController userController = Get.find();
  late final AiChatController _aiController;

  @override
  void initState() {
    super.initState();

    // Reuse the controller if it already exists.
    if (Get.isRegistered<AiChatController>()) {
      _aiController = Get.find<AiChatController>();
    } else {
      _aiController = Get.put(
        AiChatController(),
        permanent: true,
      );
    }

    _initialize();
  }

  Future<void> _initialize() async {
    await _aiController.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _aiController.isLoading.value) {
      return;
    }
    _controller.clear();
    await _aiController.sendMessage(text);
  }

  Future<void> _updateAiData() async {
    await _aiController.updateAiData();
    if (!mounted) {
      return;
    }
  }

  void _useSuggestion(String text) {
    if (_aiController.isLoading.value) {
      return;
    }
    _controller.text = text;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final user = User.fromMap(userController.current_user.toJson());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (user.role_id == 3) {
            Get.off(() => PurchaseVoucherScreen());
          } else {
            Get.off(() => SalesVoucherScreen());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome),
              SizedBox(width: 10),
              Text('AI Assistant'),
            ],
          ),
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'Update AI data',
                onPressed:
                    _aiController.isUpdatingData.value ? null : _updateAiData,
                icon: _aiController.isUpdatingData.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sync),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearChatDialog(context);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Clear chat'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        drawer: CustDrawer(
          user: User.fromMap(
            userController.current_user.toJson(),
          ),
        ),
        body: Obx(
          () => Column(
            children: [
              if (_aiController.isUpdatingData.value)
                const LinearProgressIndicator(),
              Expanded(
                child: _buildContent(),
              ),
              if (_aiController.isLoading.value) _buildLoading(),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_aiController.isInitialized.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading POS data...',
            ),
          ],
        ),
      );
    }

    if (_aiController.messages.isEmpty) {
      return _buildWelcome();
    }

    return _buildMessages();
  }

  Widget _buildWelcome() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Business Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your latest POS data is available to AI.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 28),
            _suggestion(
              'What are my best-selling products?',
            ),
            _suggestion(
              'What products are low in stock?',
            ),
            _suggestion(
              'Give me a summary of today\'s sales.',
            ),
            _suggestion(
              'Which products should I restock?',
            ),
            _suggestion(
              'How is my business performing?',
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestion(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: OutlinedButton(
        onPressed: () => _useSuggestion(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: false,
      itemCount: _aiController.messages.length,
      itemBuilder: (context, index) {
        final message = _aiController.messages[index];

        return _buildMessage(
          message,
        );
      },
    );
  }

  Widget _buildMessage(
    AiChatMessage message,
  ) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 350,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SelectableText(
          message.text,
          style: TextStyle(
            height: 1.4,
            color: message.isUser
                ? Theme.of(context).colorScheme.onPrimary
                : message.isError
                    ? Colors.red
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'AI is thinking...',
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask AI...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => IconButton.filled(
                onPressed: _aiController.isLoading.value ? null : _sendMessage,
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(context) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Clear chat?',
        ),
        content: const Text(
          'This will remove the current AI conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              _aiController.clearChat();
              Get.back();
            },
            child: const Text(
              'Clear',
            ),
          ),
        ],
      ),
    );
  }
}
