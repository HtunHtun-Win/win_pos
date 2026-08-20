import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/shop/shop_info_controller.dart';
import '../controller/sales_report_controller.dart';

class MonthlySalesReportScreen extends StatefulWidget {
  const MonthlySalesReportScreen({
    super.key,
  });

  @override
  State<MonthlySalesReportScreen> createState() =>
      _MonthlySalesReportScreenState();
}

class _MonthlySalesReportScreenState extends State<MonthlySalesReportScreen> {
  late final SalesReportController salesController;
  late final ShopInfoController shopInfoController;

  int selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> monthlySales = [];

  bool isLoading = false;

  final List<String> monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> shortMonthNames = const [
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
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await salesController.getMonthlySales(
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        monthlySales = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      debugPrint(
        'Monthly sales error: $e',
      );

      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to load monthly sales.',
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
      orElse: () => years.first,
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

        final year = value['year'];

        if (year is! int) {
          return;
        }

        setState(() {
          selectedYear = year;
        });

        _loadReport();
      },
    );
  }

  // ============================================================
  // GET MONTH TOTAL
  // ============================================================

  double _getMonthTotal(int month) {
    for (final item in monthlySales) {
      final itemMonth = _toInt(
        item['month'],
      );

      if (itemMonth == month) {
        return (item['total'] as num?)?.toDouble() ?? 0;
      }
    }

    return 0;
  }

  // ============================================================
  // TOTAL SALES
  // ============================================================

  double _getTotalSales() {
    double total = 0;

    for (int month = 1; month <= 12; month++) {
      total += _getMonthTotal(month);
    }

    return total;
  }

  // ============================================================
  // AVERAGE MONTHLY SALES
  // ============================================================

  double _getAverageSales() {
    return _getTotalSales() / 12;
  }

  // ============================================================
  // HIGHEST MONTH
  // ============================================================

  int _getHighestMonth() {
    double highest = 0;
    int highestMonth = 0;

    for (int month = 1; month <= 12; month++) {
      final total = _getMonthTotal(month);

      if (total > highest) {
        highest = total;
        highestMonth = month;
      }
    }

    return highestMonth;
  }

  // ============================================================
  // HIGHEST SALES
  // ============================================================

  double _getHighestSales() {
    double highest = 0;

    for (int month = 1; month <= 12; month++) {
      final total = _getMonthTotal(month);

      if (total > highest) {
        highest = total;
      }
    }

    return highest;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {
    final total = _getTotalSales();

    final average = _getAverageSales();

    final highestMonth = _getHighestMonth();

    final highestSales = _getHighestSales();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.point_of_sale,
                title: 'Total Sales',
                value: _formatCurrency(total),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryItem(
                icon: Icons.analytics_outlined,
                title: 'Average / Month',
                value: _formatCurrency(average),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _summaryItem(
          icon: Icons.trending_up,
          title: 'Highest Sales Month',
          value: highestMonth == 0
              ? '-'
              : '${monthNames[highestMonth - 1]} '
                  '${_formatCurrency(highestSales)}',
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 10),
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
  // SALES CHART
  // ============================================================

  Widget _salesChart() {
    if (isLoading) {
      return Card(
        elevation: 0,
        child: SizedBox(
          height: 370,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    final totalSales = _getTotalSales();

    if (totalSales <= 0) {
      return _emptyChart();
    }

    double maxValue = 0;

    for (int month = 1; month <= 12; month++) {
      final value = _getMonthTotal(month);

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      maxValue = 100;
    }

    final interval = maxValue / 5;

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
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'Monthly Sales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Sales performance for $selectedYear',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildBarGroups(),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval <= 0 ? 1 : interval,
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
                            _shortCurrency(value),
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
                              shortMonthNames[index],
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (
                        group,
                        groupIndex,
                        rod,
                        rodIndex,
                      ) {
                        final month = group.x + 1;

                        return BarTooltipItem(
                          '${monthNames[month - 1]}\n'
                          '${_formatCurrency(rod.toY)}',
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
      12,
      (index) {
        final month = index + 1;

        final total = _getMonthTotal(month);

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
  // EMPTY CHART
  // ============================================================

  Widget _emptyChart() {
    return Card(
      elevation: 0,
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
              const SizedBox(height: 10),
              Text(
                'No sales data for $selectedYear',
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
  // MONTHLY DETAILS
  // ============================================================

  Widget _monthlyList() {
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
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            separatorBuilder: (context, index) {
              return const Divider(
                height: 1,
              );
            },
            itemBuilder: (context, index) {
              final month = index + 1;

              final total = _getMonthTotal(month);

              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: Text(
                    '$month',
                  ),
                ),
                title: Text(
                  monthNames[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '$selectedYear',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  _formatCurrency(total),
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
  // INTEGER
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

  // ============================================================
  // CURRENCY
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Sales Report',
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
            const SizedBox(height: 12),

            // --------------------------------------------------
            // YEAR
            // --------------------------------------------------

            _yearDropdown(),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // SUMMARY
            // --------------------------------------------------

            _summary(),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // CHART
            // --------------------------------------------------

            _salesChart(),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // DETAILS
            // --------------------------------------------------

            _monthlyList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
