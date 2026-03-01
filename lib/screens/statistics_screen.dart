import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/database_helper.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, double> categoryData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getExpensesByCategory();
    setState(() {
      categoryData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryData.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPieChart(),
                      const SizedBox(height: 32),
                      _buildCategoryList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucune donnée disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: categoryData.entries.map((entry) {
            final percentage = (entry.value / total * 100);
            return PieChartSectionData(
              color: AppConstants.categoryColors[entry.key],
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dépenses par catégorie',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedEntries.map((entry) => _buildCategoryItem(entry)),
      ],
    );
  }

  Widget _buildCategoryItem(MapEntry<String, double> entry) {
    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    final percentage = (entry.value / total * 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppConstants.categoryColors[entry.key],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppConstants.categoryIcons[entry.key],
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: AppConstants.categoryColors[entry.key],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.value.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
