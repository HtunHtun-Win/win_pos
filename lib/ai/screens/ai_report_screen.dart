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

  String? _errorMessage;

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

  // ============================================================
  // GENERATE REPORT
  // ============================================================

  Future<void> _generateReport() async {
    if (controller.loading.value) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    controller.setLoading(true);

    try {
      final prompt = await _buildReportPrompt();

      final result = await _aiService.generateText(prompt);

      if (!mounted) {
        return;
      }

      // IMPORTANT:
      // Do not clear the previous report before generating.
      // Replace it only after successful generation.
      if (result.trim().isNotEmpty) {
        controller.setReport(result);

        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'AI returned an empty report.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      // IMPORTANT:
      // Do NOT replace the existing report with an error message.
      // The previous report remains visible.

      setState(() {
        _errorMessage = _friendlyErrorMessage(e);
      });
    } finally {
      controller.setLoading(false);
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();

    if (message.length > 250) {
      return '${message.substring(0, 250)}...';
    }

    return message;
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
      WHERE isdeleted = 0
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
      WHERE isdeleted = 0
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
      WHERE isdeleted = 0
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
      WHERE isdeleted = 0
      ''',
    );

    // ----------------------------------------------------------
    // LOW STOCK PRODUCTS
    //
    // FIX:
    // The previous query contained invalid Dart/SQL quoting:
    //
    // '''
    // ` SELECT ...
    // LIMIT 5;`
    // '''
    //
    // ----------------------------------------------------------

    final lowStockProducts = await database.rawQuery(
      '''
      SELECT
        id,
        name,
        quantity,
        sale_price
      FROM products
      WHERE isdeleted = 0
        AND COALESCE(quantity, 0) <= 5
      ORDER BY COALESCE(quantity, 0) ASC, name ASC
      LIMIT 5
      ''',
    );

    // ----------------------------------------------------------
    // TOP SALE ITEMS
    //
    // FIX:
    // Use explicit JOIN instead of:
    //
    // FROM products, sales_detail, sales
    //
    // Also group by product ID so two products with the same
    // name don't get incorrectly merged.
    // ----------------------------------------------------------

    final topSaleItems = await database.rawQuery(
      '''
      SELECT
        products.id AS product_id,
        products.name AS name,
        COALESCE(SUM(sales_detail.quantity), 0) AS quantity,
        COALESCE(
          SUM(sales_detail.quantity * sales_detail.price),
          0
        ) AS revenue
      FROM products
      INNER JOIN sales_detail
        ON products.id = sales_detail.product_id
      INNER JOIN sales
        ON sales_detail.sales_id = sales.id
      WHERE products.isdeleted = 0
        AND sales.isdeleted = 0
      GROUP BY products.id, products.name
      ORDER BY quantity DESC, revenue DESC
      LIMIT 5
      ''',
    );

    // ----------------------------------------------------------
    // LOW SALE ITEMS
    //
    // FIX:
    // Keep products with zero sales.
    //
    // sales.isdeleted = 0 must stay inside the JOIN condition.
    // If it is placed in WHERE, the LEFT JOIN becomes effectively
    // an INNER JOIN and products with no valid sales disappear.
    // ----------------------------------------------------------

    final lowSaleItems = await database.rawQuery(
      '''
      SELECT
        products.id AS product_id,
        products.name AS name,
        COALESCE(
          SUM(
            CASE
              WHEN sales.id IS NOT NULL
              THEN sales_detail.quantity
              ELSE 0
            END
          ),
          0
        ) AS quantity,
        COALESCE(
          SUM(
            CASE
              WHEN sales.id IS NOT NULL
              THEN sales_detail.quantity * sales_detail.price
              ELSE 0
            END
          ),
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
      ORDER BY quantity ASC, revenue ASC, products.name ASC
      LIMIT 5
      ''',
    );

    // ----------------------------------------------------------
    // VIP CUSTOMERS
    //
    // Explicit JOIN is easier to understand and avoids accidental
    // Cartesian joins.
    // ----------------------------------------------------------

    final vipCustomers = await database.rawQuery(
      '''
      SELECT
        customers.id AS customer_id,
        customers.name AS name,
        COALESCE(SUM(sales.total_price), 0) AS total_spent,
        COUNT(sales.id) AS vouchers
      FROM customers
      INNER JOIN sales
        ON sales.customer_id = customers.id
      WHERE sales.isdeleted = 0
      GROUP BY customers.id, customers.name
      ORDER BY total_spent DESC, vouchers DESC
      LIMIT 5
      ''',
    );

    // ==========================================================
    // SAFE DATABASE VALUES
    // ==========================================================

    final salesCount = _toInt(
      salesStats.isNotEmpty ? salesStats.first['count'] : 0,
    );

    final salesTotal = _toInt(
      salesStats.isNotEmpty ? salesStats.first['total'] : 0,
    );

    final purchaseCount = _toInt(
      purchaseStats.isNotEmpty ? purchaseStats.first['count'] : 0,
    );

    final purchaseTotal = _toInt(
      purchaseStats.isNotEmpty ? purchaseStats.first['total'] : 0,
    );

    final expenseCount = _toInt(
      expenseStats.isNotEmpty ? expenseStats.first['count'] : 0,
    );

    final expenseTotal = _toInt(
      expenseStats.isNotEmpty ? expenseStats.first['total'] : 0,
    );

    final productCount = _toInt(
      productStats.isNotEmpty ? productStats.first['count'] : 0,
    );

    final totalQuantity = _toInt(
      productStats.isNotEmpty ? productStats.first['total_quantity'] : 0,
    );

    // ==========================================================
    // BASIC BUSINESS CALCULATIONS
    // ==========================================================

    final grossDifference = salesTotal - purchaseTotal;

    final estimatedOperatingResult = salesTotal - purchaseTotal - expenseTotal;

    final averageSale = salesCount > 0 ? salesTotal ~/ salesCount : 0;

    // ==========================================================
    // LOW STOCK TEXT
    // ==========================================================

    final lowStockLines = lowStockProducts.isEmpty
        ? <String>['No products are currently below the low-stock threshold.']
        : lowStockProducts.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = _toInt(row['quantity']);

            final price = _toInt(row['sale_price']);

            return '- $name: '
                '$quantity units remaining, '
                'sale price ${_formatCurrency(price)}';
          }).toList();

    // ==========================================================
    // POPULAR ITEMS TEXT
    // ==========================================================

    final popularItemLines = topSaleItems.isEmpty
        ? <String>['No sales item data available.']
        : topSaleItems.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = _toInt(row['quantity']);

            final revenue = _toInt(row['revenue']);

            return '- $name: '
                '$quantity sold, '
                'revenue ${_formatCurrency(revenue)}';
          }).toList();

    // ==========================================================
    // VIP CUSTOMER TEXT
    // ==========================================================

    final vipCustomerLines = vipCustomers.isEmpty
        ? <String>['No VIP customer data available.']
        : vipCustomers.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final total = _toInt(row['total_spent']);

            final vouchers = _toInt(row['vouchers']);

            return '- $name: '
                '${_formatCurrency(total)} '
                'across $vouchers vouchers';
          }).toList();

    // ==========================================================
    // LOW SELLING ITEMS TEXT
    // ==========================================================

    final lowSaleItemLines = lowSaleItems.isEmpty
        ? <String>['No low-selling product data available.']
        : lowSaleItems.map((row) {
            final name = row['name']?.toString() ?? 'Unknown';

            final quantity = _toInt(row['quantity']);

            final revenue = _toInt(row['revenue']);

            return '- $name: '
                '$quantity sold, '
                'revenue ${_formatCurrency(revenue)}';
          }).toList();

    // ==========================================================
    // GENERAL PROMPT
    // ==========================================================

    final generalPrompt = '''
You are an AI analytics assistant for a small POS business.

Analyze the POS data below and answer the selected question clearly in Burmese.

Important rules:

1. Use only information supported by the provided data.
2. Do not invent customers, products, sales, expenses, or reasons.
3. If the data is insufficient to determine a reason, clearly say that it cannot be determined from the available data.
4. Give practical recommendations that a small shop owner can understand.
5. Use MMK for monetary values.
6. Keep the report structured and easy to read.
7. Do not make unsupported claims.

Selected question:
${controller.selectedQuestion.value}

POS DATA SNAPSHOT

Sales:
- Sales vouchers: $salesCount
- Sales revenue: ${_formatCurrency(salesTotal)}
- Average revenue per sales voucher: ${_formatCurrency(averageSale)}

Purchases:
- Purchase vouchers: $purchaseCount
- Purchase cost: ${_formatCurrency(purchaseTotal)}

Expenses:
- Expense records: $expenseCount
- Expenses total: ${_formatCurrency(expenseTotal)}

Inventory:
- Total products: $productCount
- Total inventory quantity: $totalQuantity

Financial indicators:
- Sales minus purchase cost: ${_formatCurrency(grossDifference)}
- Estimated result after purchases and expenses:
  ${_formatCurrency(estimatedOperatingResult)}

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

Create an overall business report.

Include:

1. Short business condition summary
2. Sales performance
3. Inventory condition
4. Financial condition
5. Current strengths
6. Current weaknesses
7. Restocking recommendations
8. Promotion recommendations
9. Cost control recommendations
10. Practical next steps

Do not claim that the business is profitable or unprofitable unless the provided numbers support the conclusion.
''';
        break;

      // --------------------------------------------------------
      // POPULAR SALE ITEMS
      // --------------------------------------------------------

      case 'Popular sale items':
        extraSection = '''
Top popular products:

${popularItemLines.join('\n')}

Analyze the best-selling products.

Explain:

1. Which products have the highest sales quantity.
2. Which products generate the most revenue based on the data.
3. Stocking recommendations.
4. Promotion opportunities.
5. Bundle opportunities.
6. Cross-selling opportunities.
7. Pricing considerations.

Do not invent reasons why customers buy these products.
''';
        break;

      // --------------------------------------------------------
      // VIP CUSTOMERS
      // --------------------------------------------------------

      case 'VIP customers by amount':
        extraSection = '''
VIP customer summary:

${vipCustomerLines.join('\n')}

Analyze customer spending.

Explain:

1. Highest-value customers.
2. Customer spending concentration.
3. Customer loyalty indicators based on voucher count.
4. Possible retention opportunities.

Give suggestions for:

1. Special offers
2. Customer retention
3. Follow-up communication
4. Loyalty rewards
5. VIP promotions

Do not claim customer preferences that are not present in the data.
''';
        break;

      // --------------------------------------------------------
      // LOW STOCK
      // --------------------------------------------------------

      case 'Low stock products':
        extraSection = '''
Low stock products:

${lowStockLines.join('\n')}

Analyze inventory risk.

Give suggestions for:

1. Restocking priority
2. Products needing urgent attention
3. Reorder timing
4. Avoiding stockouts
5. Promotion opportunities for remaining stock

Prioritize products with the lowest quantities first.
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

- Sales revenue:
  ${_formatCurrency(salesTotal)}

Give practical suggestions for:

1. Reducing unnecessary expenses
2. Managing purchases
3. Improving profit margins
4. Controlling operating costs
5. Improving business efficiency

Do not identify a specific expense as unnecessary because the expense category details are not included in this snapshot.
''';
        break;

      // --------------------------------------------------------
      // LOW SELLING ITEMS
      // --------------------------------------------------------

      case 'Low selling items':
        extraSection = '''
Low-selling products:

${lowSaleItemLines.join('\n')}

Analyze these products as slow-moving products.

Explain:

1. Which products have the weakest sales.
2. Which products have zero or very low sales.
3. Whether products may be overstocked based on the available inventory/sales information.
4. Whether pricing could potentially be a factor.
5. Whether promotion may be useful.

Important:

Do not claim a specific reason for low sales unless the available data supports it.

Give practical recommendations for:

1. Discount or promotion
2. Bundle offers
3. Cross-selling
4. Pricing strategy
5. Stock management
6. Reducing future purchases
''';
        break;

      // --------------------------------------------------------
      // DEFAULT
      // --------------------------------------------------------

      default:
        extraSection = '''
Low stock products:

${lowStockLines.join('\n')}

Include:

1. Current strengths
2. Current weaknesses
3. Restocking recommendations
4. Promotion recommendations
5. Cost control recommendations
6. Practical next steps
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

    if (value is num) {
      return value.toInt();
    }

    final stringValue = value.toString();

    return int.tryParse(stringValue) ??
        double.tryParse(stringValue)?.toInt() ??
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
  // QUESTION DROPDOWN
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
            isExpanded: true,
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
                  child: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
            onChanged: controller.loading.value
                ? null
                : (value) {
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
  // ERROR MESSAGE
  // ============================================================

  Widget _buildErrorMessage() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(
        top: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Could not generate the new report',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your previous report is still available.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              icon: const Icon(
                Icons.close,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _buildReportHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'AI Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REPORT UI
  // ============================================================

  Widget _buildReport() {
    return Obx(
      () {
        final report = controller.report.value;

        // --------------------------------------------------------
        // EMPTY REPORT
        // --------------------------------------------------------

        if (report.trim().isEmpty) {
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

        // --------------------------------------------------------
        // EXISTING REPORT
        // --------------------------------------------------------

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader(),

                const SizedBox(height: 8),

                Text(
                  controller.selectedQuestion.value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const Divider(
                  height: 28,
                ),

                // ------------------------------------------------
                // KEEP OLD REPORT VISIBLE WHILE GENERATING
                // ------------------------------------------------

                SelectableText(
                  report,
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),

                // ------------------------------------------------
                // GENERATING INDICATOR
                // ------------------------------------------------

                if (controller.loading.value) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Generating a new report... '
                          'Your current report is still available.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GENERATE BUTTON
  // ============================================================

  Widget _buildGenerateButton() {
    return Obx(
      () {
        final loading = controller.loading.value;

        return SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: loading ? null : _generateReport,
            icon: loading
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
              loading ? 'Generating...' : _generateButtonLabel(),
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
    final user = User.fromMap(
      userController.current_user.toJson(),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (user.role_id == 3) {
            Get.off(
              () => PurchaseVoucherScreen(),
            );
          } else {
            Get.off(
              () => SalesVoucherScreen(),
            );
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
              const SizedBox(height: 8),

              // --------------------------------------------------
              // QUESTION
              // --------------------------------------------------

              _buildQuestionDropdown(),

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              _buildErrorMessage(),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // REPORT
              // --------------------------------------------------

              _buildReport(),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // GENERATE BUTTON
              // --------------------------------------------------

              _buildGenerateButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
