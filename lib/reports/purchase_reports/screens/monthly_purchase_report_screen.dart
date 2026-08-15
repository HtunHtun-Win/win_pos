import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';

import '../controller/purchase_report_controller.dart';

class MonthlyPurchaseReportScreen extends StatefulWidget {
  const MonthlyPurchaseReportScreen({
    super.key,
  });

  @override
  State<MonthlyPurchaseReportScreen> createState() =>
      _MonthlyPurchaseReportScreenState();
}

class _MonthlyPurchaseReportScreenState
    extends State<MonthlyPurchaseReportScreen> {
  late final PurchaseReportController purchaseController;

  late final SupplierController supplierController;

  int? supplierId;

  int selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> monthlyPurchase = [];

  bool isLoading = false;

  final List<String> monthNames = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();

    purchaseController = Get.put(
      PurchaseReportController(),
    );

    supplierController = Get.put(
      SupplierController(),
    );

    _loadInitialData();
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================

  Future<void> _loadInitialData() async {
    await supplierController.getAll();

    await _loadReport();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await purchaseController.getMonthlyPurchase(
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        monthlyPurchase = result;
      });
    } catch (e) {
      debugPrint(
        'Monthly purchase error: $e',
      );

      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to load purchase report.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // YEAR DROPDOWN
  // ============================================================

  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> years = [
      {
        'label': 'This Year ($currentYear)',
        'year': currentYear,
      },
      {
        'label': 'Last Year (${currentYear - 1})',
        'year': currentYear - 1,
      },
      {
        'label': 'Last 2 Years (${currentYear - 2})',
        'year': currentYear - 2,
      },
      {
        'label': 'Last 3 Years (${currentYear - 3})',
        'year': currentYear - 3,
      },
    ];

    final selected = years.firstWhere(
      (item) => item['year'] == selectedYear,
    );

    return DropdownSearch<Map<String, dynamic>>(
      items: years,
      selectedItem: selected,
      itemAsString: (item) => item['label'].toString(),
      popupProps: const PopupProps.menu(
        showSearchBox: false,
      ),
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Select Year',
          prefixIcon: Icon(
            Icons.calendar_month,
          ),
          border: OutlineInputBorder(),
        ),
      ),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          selectedYear = value['year'] as int;
        });
        _loadReport();
      },
    );
  }

  // ============================================================
  // TOTAL PURCHASE
  // ============================================================

  double _getTotalPurchase() {
    double total = 0;

    for (final item in monthlyPurchase) {
      total += (item['total'] as num?)?.toDouble() ?? 0;
    }

    return total;
  }

  // ============================================================
  // AVERAGE
  // ============================================================

  double _getAveragePurchase() {
    if (monthlyPurchase.isEmpty) {
      return 0;
    }

    return _getTotalPurchase() / monthlyPurchase.length;
  }

  // ============================================================
  // HIGHEST MONTH
  // ============================================================

  Map<String, dynamic>? _getHighestMonth() {
    if (monthlyPurchase.isEmpty) {
      return null;
    }

    Map<String, dynamic>? highest;

    double highestValue = -1;

    for (final item in monthlyPurchase) {
      final total = (item['total'] as num?)?.toDouble() ?? 0;

      if (total > highestValue) {
        highestValue = total;
        highest = item;
      }
    }

    return highest;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {
    final total = _getTotalPurchase();

    final average = _getAveragePurchase();

    final highest = _getHighestMonth();

    String highestText = '-';

    if (highest != null) {
      final month = _toInt(highest['month']);

      final amount = (highest['total'] as num?)?.toDouble() ?? 0;

      highestText = '${monthNames[month - 1]} '
          '${_formatCurrency(amount)}';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.shopping_cart,
                title: 'Total Purchase',
                value: _formatCurrency(
                  total,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _summaryItem(
                icon: Icons.analytics_outlined,
                title: 'Average / Month',
                value: _formatCurrency(
                  average,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        _summaryItem(
          icon: Icons.trending_up,
          title: 'Highest Purchase Month',
          value: highestText,
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHART
  // ============================================================

  Widget _chart() {
    if (isLoading) {
      return const Card(
        child: SizedBox(
          height: 350,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (monthlyPurchase.isEmpty) {
      return _emptyChart();
    }

    double maxValue = 0;

    for (final item in monthlyPurchase) {
      final total = (item['total'] as num?)?.toDouble() ?? 0;

      if (total > maxValue) {
        maxValue = total;
      }
    }

    if (maxValue <= 0) {
      maxValue = 100;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          10,
          20,
          20,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 6,
              ),
              child: Text(
                'Monthly Purchase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 6,
              ),
              child: Text(
                'Purchase spending in $selectedYear',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildBars(),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 5,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _shortCurrency(
                              value,
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= 12) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Text(
                              monthNames[index],
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BARS
  // ============================================================

  List<BarChartGroupData> _buildBars() {
    return List.generate(
      monthlyPurchase.length,
      (index) {
        final total =
            (monthlyPurchase[index]['total'] as num?)?.toDouble() ?? 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Widget _details() {
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Monthly Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(
            height: 1,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthlyPurchase.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
            ),
            itemBuilder: (context, index) {
              final month = _toInt(
                monthlyPurchase[index]['month'],
              );

              final total =
                  (monthlyPurchase[index]['total'] as num?)?.toDouble() ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    monthNames[month - 1].substring(
                      0,
                      1,
                    ),
                  ),
                ),
                title: Text(
                  monthNames[month - 1],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  _formatCurrency(
                    total,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyChart() {
    return Card(
      child: SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 50,
                color: Colors.grey.shade400,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'No purchase data',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _formatCurrency(
    double value,
  ) {
    return '${value.toInt().toString().replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        )} MMK';
  }

  String _shortCurrency(
    double value,
  ) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }

    return value.toInt().toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Purchase Report',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : _loadReport,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            const SizedBox(
              height: 12,
            ),

            // --------------------------------------------------
            // YEAR
            // --------------------------------------------------

            _yearDropdown(),

            const SizedBox(
              height: 16,
            ),

            // --------------------------------------------------
            // SUMMARY
            // --------------------------------------------------

            _summary(),

            const SizedBox(
              height: 16,
            ),

            // --------------------------------------------------
            // CHART
            // --------------------------------------------------

            _chart(),

            const SizedBox(
              height: 16,
            ),

            // --------------------------------------------------
            // DETAILS
            // --------------------------------------------------

            _details(),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
