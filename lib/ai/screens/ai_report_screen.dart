import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/ai/controllers/ai_report_controller.dart';
import 'package:win_pos/ai/services/ai_service.dart';
import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({super.key});

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  final AiService _aiService = AiService();
  final DbHelper _dbHelper = DbHelper();
  late final AiReportController controller;
  final UserController userController = Get.find();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AiReportController>()) {
      controller = Get.find<AiReportController>();
    } else {
      controller = Get.put(
        AiReportController(),
        permanent: true,
      );
    }
  }

  Future<void> _generateReport() async {
    controller.setLoading(true);

    try {
      final prompt = await _buildReportPrompt();

      final result = await _aiService.generateText(prompt);

      controller.setReport(result);
    } catch (e) {
      controller.setReport(
        'Failed to generate report.\n\n$e',
      );
    } finally {
      controller.setLoading(false);
    }
  }

  // ============================================================
  // BUILD AI PROMPT
  // ============================================================

  Future<String> _buildReportPrompt() async {
    final database = await _dbHelper.database;

    // ----------------------------------------------------------
    // SALES
    // ----------------------------------------------------------

    final salesStats = await database.rawQuery(
      '''
      SELECT 
        COUNT(*) AS count,
        COALESCE(SUM(total_price), 0) AS total
      FROM sales
      WHERE isdeleted = 0;
      ''',
    );

    // ----------------------------------------------------------
    // PURCHASE
    // ----------------------------------------------------------

    final purchaseStats = await database.rawQuery(
      '''
      SELECT 
        COUNT(*) AS count,
        COALESCE(SUM(total_price), 0) AS total
      FROM purchase
      WHERE isdeleted = 0;
      ''',
    );

    // ----------------------------------------------------------
    // EXPENSE
    // ----------------------------------------------------------

    final expenseStats = await database.rawQuery(
      '''
      SELECT 
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total
      FROM income_expense
      WHERE isdeleted = 0;
      ''',
    );

    // ----------------------------------------------------------
    // PRODUCTS
    // ----------------------------------------------------------

    final productStats = await database.rawQuery(
      '''
      SELECT 
        COUNT(*) AS count,
        COALESCE(SUM(quantity), 0) AS total_quantity
      FROM products
      WHERE isdeleted = 0;
      ''',
    );

    // ----------------------------------------------------------
    // LOW STOCK PRODUCTS
    // ----------------------------------------------------------

    final lowStockProducts = await database.rawQuery(
      '''
`      SELECT 
        name,
        quantity,
        sale_price
      FROM products
      WHERE isdeleted = 0
        AND quantity <= 5
      ORDER BY quantity ASC
      LIMIT 5;`
      ''',
    );

    // ----------------------------------------------------------
    // TOP SALE ITEMS
    // ----------------------------------------------------------

    final topSaleItems = await database.rawQuery(
      '''
      SELECT 
        products.name,
        SUM(sales_detail.quantity) AS quantity,
        SUM(
          sales_detail.quantity * sales_detail.price
        ) AS revenue
      FROM products, sales_detail, sales
      WHERE products.id = sales_detail.product_id
        AND sales_detail.sales_id = sales.id
        AND sales.isdeleted = 0
      GROUP BY products.name
      ORDER BY quantity DESC
      LIMIT 5;
      ''',
    );

    // ----------------------------------------------------------
// LOW SALE ITEMS
// ----------------------------------------------------------

    final lowSaleItems = await database.rawQuery(
      '''
  SELECT 
    products.name,
    COALESCE(SUM(sales_detail.quantity), 0) AS quantity,
    COALESCE(
      SUM(sales_detail.quantity * sales_detail.price),
      0
    ) AS revenue
  FROM products
  LEFT JOIN sales_detail
    ON products.id = sales_detail.product_id
  LEFT JOIN sales
    ON sales_detail.sales_id = sales.id
    AND sales.isdeleted = 0
  WHERE products.isdeleted = 0
  GROUP BY products.id, products.name
  ORDER BY quantity ASC
  LIMIT 5;
  ''',
    );

    // ----------------------------------------------------------
    // VIP CUSTOMERS
    // ----------------------------------------------------------

    final vipCustomers = await database.rawQuery(
      '''
      SELECT 
        customers.name,
        SUM(sales.total_price) AS total_spent,
        COUNT(*) AS vouchers
      FROM sales, customers
      WHERE sales.customer_id = customers.id
        AND sales.isdeleted = 0
      GROUP BY customers.id, customers.name
      ORDER BY total_spent DESC
      LIMIT 5;
      ''',
    );

    // ==========================================================
    // CONVERT DATABASE VALUES
    // ==========================================================

    final salesCount = _toInt(salesStats.first['count']);

    final salesTotal = _toInt(salesStats.first['total']);

    final purchaseCount = _toInt(purchaseStats.first['count']);

    final purchaseTotal = _toInt(purchaseStats.first['total']);

    final expenseCount = _toInt(expenseStats.first['count']);

    final expenseTotal = _toInt(expenseStats.first['total']);

    final productCount = _toInt(productStats.first['count']);

    final totalQuantity = _toInt(productStats.first['total_quantity']);

    // ==========================================================
    // LOW STOCK TEXT
    // ==========================================================

    final lowStockLines = lowStockProducts.isEmpty
        ? [
            'No products are currently below the '
                'low-stock threshold.'
          ]
        : lowStockProducts.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = row['quantity']?.toString() ?? '0';

            final price = row['sale_price']?.toString() ?? '0';

            return '- $name: '
                '$quantity units remaining, '
                'sale price $price';
          }).toList();

    // ==========================================================
    // POPULAR ITEMS TEXT
    // ==========================================================

    final popularItemLines = topSaleItems.isEmpty
        ? ['No sales item data available.']
        : topSaleItems.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = row['quantity']?.toString() ?? '0';

            final revenue = row['revenue']?.toString() ?? '0';

            return '- $name: '
                '$quantity sold, '
                'revenue ${_formatCurrency(
              _toInt(revenue),
            )}';
          }).toList();

    // ==========================================================
    // VIP CUSTOMER TEXT
    // ==========================================================

    final vipCustomerLines = vipCustomers.isEmpty
        ? ['No VIP customer data available.']
        : vipCustomers.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final total = row['total_spent']?.toString() ?? '0';

            final vouchers = row['vouchers']?.toString() ?? '0';

            return '- $name: '
                '${_formatCurrency(
              _toInt(total),
            )} '
                'across $vouchers vouchers';
          }).toList();

    // ==========================================================
    // LOW SELLING ITEMS TEXT
    // ==========================================================

    final lowSaleItemLines = lowSaleItems.isEmpty
        ? ['No low-selling product data available.']
        : lowSaleItems.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = row['quantity']?.toString() ?? '0';

            final revenue = row['revenue']?.toString() ?? '0';

            return '- $name: '
                '$quantity sold, '
                'revenue ${_formatCurrency(
              _toInt(revenue),
            )}';
          }).toList();

    // ==========================================================
    // GENERAL PROMPT
    // ==========================================================

    final generalPrompt = '''
You are an AI analytics assistant for a small POS business.

Use the data below to answer the selected question clearly in Burmese.

Include practical suggestions for the shop owner.

Question: ${controller.selectedQuestion.value}

POS data snapshot:

- Sales vouchers: $salesCount
- Sales revenue: ${_formatCurrency(salesTotal)}

- Purchase vouchers: $purchaseCount
- Purchase cost: ${_formatCurrency(purchaseTotal)}

- Expense records: $expenseCount
- Expenses total: ${_formatCurrency(expenseTotal)}

- Total products: $productCount
- Total inventory quantity: $totalQuantity

''';

    // ==========================================================
    // QUESTION-SPECIFIC PROMPT
    // ==========================================================

    String extraSection;

    switch (controller.selectedQuestion.value) {
      // --------------------------------------------------------
      // OVERALL REPORT
      // --------------------------------------------------------

      case 'Overall business report':
        extraSection = '''
Low stock products:

${lowStockLines.join('\n')}

Also include:

1. A short summary of the current business condition.
2. Current strengths.
3. Current weaknesses.
4. Sales recommendations.
5. Restocking recommendations.
6. Promotion recommendations.
7. Cost control recommendations.

Give practical advice that a small shop owner can understand.
''';
        break;

      // --------------------------------------------------------
      // POPULAR SALE ITEMS
      // --------------------------------------------------------

      case 'Popular sale items':
        extraSection = '''
Top popular products:

${popularItemLines.join('\n')}

Explain why these products may be selling well.

Give suggestions for:

1. Promotion
2. Stocking
3. Bundle offers
4. Cross-selling
5. Pricing strategy
''';
        break;

      // --------------------------------------------------------
      // VIP CUSTOMERS
      // --------------------------------------------------------

      case 'VIP customers by amount':
        extraSection = '''
VIP customer summary:

${vipCustomerLines.join('\n')}

Explain what this means for customer loyalty.

Give suggestions for:

1. Special offers
2. Customer retention
3. Follow-up communication
4. Loyalty rewards
5. VIP customer promotions
''';
        break;

      // --------------------------------------------------------
      // LOW STOCK
      // --------------------------------------------------------

      case 'Low stock products':
        extraSection = '''
Low stock products:

${lowStockLines.join('\n')}

Give suggestions for:

1. Restocking priority
2. Reorder timing
3. Products that need urgent attention
4. Avoiding stockouts
5. Promotions for remaining stock
''';
        break;

      // --------------------------------------------------------
      // EXPENSE CONTROL
      // --------------------------------------------------------

      case 'Expense control suggestions':
        extraSection = '''
Expense and cost snapshot:

- Total expenses:
  ${_formatCurrency(expenseTotal)}

- Purchase cost:
  ${_formatCurrency(purchaseTotal)}

Give practical suggestions for:

1. Reducing unnecessary expenses
2. Managing purchases
3. Improving profit margins
4. Controlling operating costs
5. Improving business efficiency
''';
        break;

      ///
      case 'Low selling items':
        extraSection = '''
Low-selling products:

${lowSaleItemLines.join('\n')}

Analyze these products as slow-moving products.

Explain:

1. Which products have the weakest sales.
2. Possible reasons for low sales.
3. Whether the products may be overstocked.
4. Whether the pricing could be a problem.
5. Whether the products may need better promotion.

Give practical recommendations for:

1. Discount or promotion
2. Bundle offers
3. Cross-selling
4. Pricing strategy
5. Stock management
6. Whether to reduce future purchases

Do not claim a specific reason unless the available data supports it.
''';
        break;

      // --------------------------------------------------------
      // DEFAULT
      // --------------------------------------------------------

      default:
        extraSection = '''
Low stock products:

${lowStockLines.join('\n')}

Also include:

1. Current strengths
2. Current weaknesses
3. Restocking recommendations
4. Promotion recommendations
5. Cost control recommendations
''';
    }

    return '$generalPrompt$extraSection';
  }

  // ============================================================
  // SAFE INTEGER CONVERSION
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        double.tryParse(
          value.toString(),
        )?.toInt() ??
        0;
  }

  // ============================================================
  // FORMAT CURRENCY
  // ============================================================

  String _formatCurrency(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )} MMK';
  }

  // ============================================================
  // BUTTON LABEL
  // ============================================================

  String _generateButtonLabel() {
    if (controller.selectedQuestion.value == 'Overall business report') {
      return 'Generate AI Report';
    }

    return 'Generate "${controller.selectedQuestion.value}"';
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildQuestionDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.selectedQuestion.value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Choose AI question',
              prefixIcon: Icon(
                Icons.help_outline,
              ),
            ),
            items: controller.questionOptions.map(
              (option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              controller.setQuestion(value);
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REPORT UI
  // ============================================================

  Widget _buildReport() {
    return Obx(
      () {
        final report = controller.report.value;

        if (report.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 50,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No AI report yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a question and generate '
                    'a report to analyze your POS data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    controller.selectedQuestion.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Divider(
                  height: 28,
                ),
                SelectableText(
                  report,
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              Icon(
                Icons.analytics_outlined,
              ),
              SizedBox(width: 10),
              Text('AI Report'),
            ],
          ),
        ),
        drawer: CustDrawer(
          user: User.fromMap(
            userController.current_user.toJson(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _generateReport,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),

              // --------------------------------------------------
              // QUESTION DROPDOWN
              // --------------------------------------------------

              _buildQuestionDropdown(),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // REPORT
              // --------------------------------------------------

              _buildReport(),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // GENERATE BUTTON
              // --------------------------------------------------

              Obx(
                () => SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed:
                        controller.loading.value ? null : _generateReport,
                    icon: controller.loading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                          ),
                    label: Text(
                      controller.loading.value
                          ? 'Generating...'
                          : _generateButtonLabel(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
