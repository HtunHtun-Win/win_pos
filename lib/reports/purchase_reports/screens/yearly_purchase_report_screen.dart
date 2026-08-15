import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';

import '../controller/purchase_report_controller.dart';

class YearlyPurchaseReportScreen extends StatefulWidget {
  const YearlyPurchaseReportScreen({
    super.key,
  });

  @override
  State<YearlyPurchaseReportScreen> createState() =>
      _YearlyPurchaseReportScreenState();
}

class _YearlyPurchaseReportScreenState
    extends State<YearlyPurchaseReportScreen> {
  late final PurchaseReportController purchaseController;

  late final SupplierController supplierController;

  int? supplierId;

  List<Map<String, dynamic>> yearlyPurchase = [];

  bool isLoading = false;

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
  // INITIAL LOAD
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
      final result = await purchaseController.getYearlyPurchase();

      if (!mounted) return;

      setState(() {
        yearlyPurchase = result;
      });
    } catch (e) {
      debugPrint(
        'Yearly purchase error: $e',
      );

      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to load yearly purchase report.',
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
  // TOTAL PURCHASE
  // ============================================================

  double _getTotalPurchase() {
    double total = 0;

    for (final item in yearlyPurchase) {
      total += (item['total'] as num?)?.toDouble() ?? 0;
    }

    return total;
  }

  // ============================================================
  // AVERAGE
  // ============================================================

  double _getAveragePurchase() {
    if (yearlyPurchase.isEmpty) {
      return 0;
    }

    return _getTotalPurchase() / yearlyPurchase.length;
  }

  // ============================================================
  // CURRENT YEAR PURCHASE
  // ============================================================

  double _getCurrentYearPurchase() {
    final currentYear = DateTime.now().year;

    for (final item in yearlyPurchase) {
      if (item['year'] == currentYear) {
        return (item['total'] as num?)?.toDouble() ?? 0;
      }
    }

    return 0;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {
    final total = _getTotalPurchase();

    final currentYear = _getCurrentYearPurchase();

    final average = _getAveragePurchase();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.shopping_cart_outlined,
                title: '6 Year Purchase',
                value: _formatCurrency(total),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _summaryItem(
                icon: Icons.calendar_today,
                title: 'This Year',
                value: _formatCurrency(
                  currentYear,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.analytics_outlined,
                title: 'Average / Year',
                value: _formatCurrency(
                  average,
                ),
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 7,
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
              height: 9,
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
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
          height: 380,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (yearlyPurchase.isEmpty) {
      return _emptyChart();
    }

    double maxValue = 0;

    for (final item in yearlyPurchase) {
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
                'Yearly Purchase',
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
                'Purchase spending for the last 6 years',
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

                          if (index < 0 || index >= yearlyPurchase.length) {
                            return const SizedBox();
                          }

                          final year = yearlyPurchase[index]['year'];

                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Text(
                              year.toString(),
                              style: const TextStyle(
                                fontSize: 11,
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
  // BAR GROUPS
  // ============================================================

  List<BarChartGroupData> _buildBars() {
    return List.generate(
      yearlyPurchase.length,
      (index) {
        final total = (yearlyPurchase[index]['total'] as num?)?.toDouble() ?? 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 28,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // YEARLY DETAILS
  // ============================================================

  Widget _details() {
    final currentYear = DateTime.now().year;

    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Yearly Details',
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
            itemCount: yearlyPurchase.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
            ),
            itemBuilder: (context, index) {
              final year = _toInt(
                yearlyPurchase[index]['year'],
              );

              final total =
                  (yearlyPurchase[index]['total'] as num?)?.toDouble() ?? 0;

              final isCurrentYear = year == currentYear;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    year.toString().substring(2),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      year.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentYear)
                      Container(
                        margin: const EdgeInsets.only(
                          left: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
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
          'Yearly Purchase Report',
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
