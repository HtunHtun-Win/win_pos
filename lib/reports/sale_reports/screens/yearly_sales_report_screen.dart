import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/shop/shop_info_controller.dart';

import '../controller/sales_report_controller.dart';

class YearlySalesReportScreen extends StatefulWidget {
  const YearlySalesReportScreen({
    super.key,
  });

  @override
  State<YearlySalesReportScreen> createState() =>
      _YearlySalesReportScreenState();
}

class _YearlySalesReportScreenState extends State<YearlySalesReportScreen> {
  late final SalesReportController salesController;

  late final ShopInfoController shopInfoController;

  int? customerId;

  List<Map<String, dynamic>> yearlySales = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    salesController = Get.put(
      SalesReportController(),
    );

    shopInfoController = Get.find<ShopInfoController>();

    _loadInitialData();
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadReport(),
      shopInfoController.getAll(),
    ]);
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await salesController.getYearlySales();

      if (!mounted) return;

      setState(() {
        yearlySales = result;
      });
    } catch (e) {
      debugPrint(
        'Yearly sales error: $e',
      );

      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to load yearly sales.',
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
  // TOTAL SALES
  // ============================================================

  double _getTotalSales() {
    double total = 0;

    for (final item in yearlySales) {
      total += (item['total'] as num?)?.toDouble() ?? 0;
    }

    return total;
  }

  // ============================================================
  // AVERAGE SALES
  // ============================================================

  double _getAverageSales() {
    if (yearlySales.isEmpty) {
      return 0;
    }

    return _getTotalSales() / yearlySales.length;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summaryCard() {
    final total = _getTotalSales();

    final average = _getAverageSales();

    final currentYear = DateTime.now().year;

    double currentYearSales = 0;

    for (final item in yearlySales) {
      if (item['year'] == currentYear) {
        currentYearSales = (item['total'] as num?)?.toDouble() ?? 0;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.attach_money,
                title: '6 Year Sales',
                value: _formatCurrency(total),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryItem(
                icon: Icons.trending_up,
                title: 'This Year',
                value: _formatCurrency(
                  currentYearSales,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _summaryItem(
          icon: Icons.analytics_outlined,
          title: 'Average Per Year',
          value: _formatCurrency(average),
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
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // YEARLY CHART
  // ============================================================

  Widget _yearlyChart() {
    if (isLoading) {
      return Card(
        child: SizedBox(
          height: 380,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (yearlySales.isEmpty) {
      return _emptyChart();
    }

    double maxValue = 0;

    for (final item in yearlySales) {
      final value = (item['total'] as num?)?.toDouble() ?? 0;

      if (value > maxValue) {
        maxValue = value;
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
                'Yearly Sales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(
                left: 6,
              ),
              child: Text(
                'Sales for the last 6 years',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
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
                  barGroups: _buildBarGroups(),
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

                          if (index < 0 || index >= yearlySales.length) {
                            return const SizedBox();
                          }

                          final year = yearlySales[index]['year'];

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

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(
      yearlySales.length,
      (index) {
        final total = (yearlySales[index]['total'] as num?)?.toDouble() ?? 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 28,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(
                  6,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // YEARLY DETAIL LIST
  // ============================================================

  Widget _yearlyList() {
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
            itemCount: yearlySales.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
            ),
            itemBuilder: (context, index) {
              final year = yearlySales[index]['year'];

              final total =
                  (yearlySales[index]['total'] as num?)?.toDouble() ?? 0;

              final isCurrentYear = year == DateTime.now().year;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    '$year'.substring(
                      2,
                    ),
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
                Icons.bar_chart,
                size: 50,
                color: Colors.grey.shade400,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'No sales data',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT CURRENCY
  // ============================================================

  String _formatCurrency(
    double value,
  ) {
    final number = value.toInt();

    return '${number.toString().replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        )} MMK';
  }

  // ============================================================
  // SHORT CURRENCY
  // ============================================================

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
          'Yearly Sales Report',
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

            _summaryCard(),

            const SizedBox(
              height: 16,
            ),

            // --------------------------------------------------
            // CHART
            // --------------------------------------------------

            _yearlyChart(),

            const SizedBox(
              height: 16,
            ),

            // --------------------------------------------------
            // DETAILS
            // --------------------------------------------------

            _yearlyList(),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
