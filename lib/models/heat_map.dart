import 'package:flutter/material.dart';

class GitHubHeatmap extends StatelessWidget {
  final DateTime startDate;
  final int totalWeeks;
  final Map<DateTime, int> data;
  final double cellSize;
  final double spacing;
  final List<Color> colorLevels;

  const GitHubHeatmap({
    required this.startDate,
    required this.totalWeeks,
    required this.data,
    this.cellSize = 15,
    this.spacing = 2,
    this.colorLevels = const [
      Color(0xFFEBEDF0), // 等级0
      Color.fromRGBO(197, 232, 231, 1), // 等级1
      Color.fromRGBO(160, 216, 219, 1), // 等级2
      Color.fromRGBO(91, 171, 170, 1), // 等级3
      Color.fromRGBO(52, 125, 124, 1), // 等级4
    ],
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekColumns = _generateWeekColumns();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: weekColumns.map((week) => _buildWeekColumn(week)).toList(),
        ),
      ),
    );
  }

  List<List<DateTime?>> _generateWeekColumns() {
    final weeks = <List<DateTime?>>[];
    DateTime currentMonday = _getPreviousMonday(startDate);
    final DateTime today = DateTime.now();

    for (int week = 0; week < totalWeeks; week++) {
      final weekDays = <DateTime?>[];
      for (int day = 0; day < 7; day++) {
        final date = currentMonday.add(Duration(days: day));
        // 如果日期超过今天，则不渲染
        if (date.isAfter(today)) {
          weekDays.add(null); // 使用 null 表示未来的日期
        } else {
          weekDays.add(date);
        }
      }
      weeks.add(weekDays);
      currentMonday = currentMonday.add(const Duration(days: 7));

      // 如果当前周的日期已经超过今天，则停止生成
      if (currentMonday.isAfter(today)) {
        break;
      }
    }
    return weeks;
  }

  DateTime _getPreviousMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Widget _buildWeekColumn(List<DateTime?> weekDays) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: weekDays.map((date) {
        return Tooltip(
          message: date != null
              ? '日期: ${_formatDate(date)}\n活跃等级: ${data[date] ?? 0}'
              : '无数据',
          child: Container(
            width: cellSize,
            height: cellSize,
            margin: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: _getColorForDate(date),
              borderRadius: BorderRadius.circular(3), // 圆角微调
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForDate(DateTime? date) {
    if (date == null) return colorLevels[0];
    final value = data[date] ?? 0;
    return colorLevels[value.clamp(0, colorLevels.length - 1)];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}