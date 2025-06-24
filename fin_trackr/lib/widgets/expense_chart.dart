import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final double income;
  final double expense;

  const ExpenseChart({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    if (total == 0) return const SizedBox();

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  value: income,
                  color: const Color(0xFF00C897), // Income color
                  title: '${((income / total) * 100).toStringAsFixed(0)}%',
                  radius: 65,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: _buildBadge(Icons.arrow_downward, Colors.green),
                  badgePositionPercentageOffset: .85,
                ),
                PieChartSectionData(
                  value: expense,
                  color: const Color(0xFFE14D72), // Expense color
                  title: '${((expense / total) * 100).toStringAsFixed(0)}%',
                  radius: 65,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: _buildBadge(Icons.arrow_upward, Colors.red),
                  badgePositionPercentageOffset: .85,
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              "📊\nAnalytics",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBadge(IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }
}
