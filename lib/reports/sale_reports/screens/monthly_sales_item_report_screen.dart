import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/service/show_toast.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/shop/shop_info_controller.dart';
import '../controller/sales_report_controller.dart';

class MonthlySalesItemReportScreen extends StatefulWidget {
  const MonthlySalesItemReportScreen({
    super.key,
  });

  @override
  State<MonthlySalesItemReportScreen> createState() =>
      _MonthlySalesItemReportScreenState();
}

class _MonthlySalesItemReportScreenState
    extends State<MonthlySalesItemReportScreen> {
  late final SalesReportController salesReportController;
  late final ShopInfoController shopInfoController;
  late final ProductController productController;

  int selectedYear = DateTime.now().year;

  int? selectedProductId;

  List<Map<String, dynamic>> monthlySales = [];

  bool isLoading = false;
  bool isInitializing = true;

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

    salesReportController = Get.put(
      SalesReportController(),
    );

    productController = Get.put(
      ProductController(),
    );

    shopInfoController = Get.find<ShopInfoController>();

    _initialize();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    try {
      await Future.wait([
        productController.getAll(),
        // shopInfoController.getAll(),
      ]);

      if (!mounted) return;

      if (productController.products.isNotEmpty) {
        selectedProductId = _toInt(productController.products.first['id']);

        await _loadReport();
      }
    } catch (e) {
      debugPrint('Initialize error: $e');

      if (mounted) {
        ShowToast.showNotiToast(msg: "Failed to load products.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    if (selectedProductId == null) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await salesReportController.getMonthlySalesItem(
        year: selectedYear,
        productId: selectedProductId!,
      );

      if (!mounted) return;

      setState(() {
        monthlySales = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      debugPrint(
        'Monthly sales item error: $e',
      );

      if (!mounted) return;

      ShowToast.showNotiToast(msg: "Failed to load monthly sales.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PRODUCT DROPDOWN
  // ============================================================
  Widget _productDropdown() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select Item...",
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: productController.products
          .map((product) => product.name.toString())
          .toList(),
      onChanged: (value) {
        final item = productController.products.firstWhere(
          (product) => product.name == value,
        );
        setState(() {
          selectedProductId = item.id;
        });
        _loadReport();
        // currentQty = item.quantity;
        // productController.selectedProduct['pid'] = pId!;
        // productController.selectedProduct['qty'] = currentQty!;
      },
      selectedItem: null,
      // Optional: Can be null if no initial selection is required
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Select Item",
          ),
        ),
      ),
    );
  }

  // ============================================================
  // YEAR DROPDOWN
  // ============================================================

  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;

    final years = [
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
      itemAsString: (item) {
        return item['label'].toString();
      },
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
  // TOTAL
  // ============================================================

  double _getTotalSales() {
    double total = 0;

    for (int month = 1; month <= 12; month++) {
      total += _getMonthTotal(month);
    }

    return total;
  }

  // ============================================================
  // AVERAGE
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
  // SELECTED PRODUCT NAME
  // ============================================================

  String _getSelectedProductName() {
    if (selectedProductId == null) {
      return '-';
    }

    for (final product in productController.products) {
      if (_toInt(product.id) == selectedProductId) {
        return product.name?.toString() ?? '-';
      }
    }

    return '-';
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
  // CHART
  // ============================================================

  Widget _salesChart() {
    if (isLoading) {
      return const Card(
        child: SizedBox(
          height: 370,
          child: Center(
            child: CircularProgressIndicator(),
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
                '${_getSelectedProductName()} • $selectedYear',
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
                  minY: 0,
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
  // EMPTY
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
              return const Divider(height: 1);
            },
            itemBuilder: (context, index) {
              final month = index + 1;
              final total = _getMonthTotal(month);

              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: Text('$month'),
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
  // HELPERS
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatCurrency(double value) {
    final number = value.toInt();

    return '${number.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )} MMK';
  }

  String _shortCurrency(double value) {
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
    if (isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final hasProducts = productController.products.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Sales Item Report',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : _initialize,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: !hasProducts
          ? const Center(
              child: Text(
                'No products available.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  const SizedBox(height: 12),

                  // PRODUCT
                  _productDropdown(),

                  const SizedBox(height: 12),

                  // YEAR
                  _yearDropdown(),

                  const SizedBox(height: 16),

                  // SUMMARY
                  _summary(),

                  const SizedBox(height: 16),

                  // CHART
                  _salesChart(),

                  const SizedBox(height: 16),

                  // DETAILS
                  _monthlyList(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
