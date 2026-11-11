import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_summary.dart';

/// Total revenue for the range with a line chart of how it built up.
class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key, required this.summary});

  final AnalyticsSummary summary;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
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

  String _labelFor(DateTime start) => switch (summary.range) {
    AnalyticsRange.today => '${start.hour}h',
    AnalyticsRange.week => _weekdays[start.weekday - 1],
    AnalyticsRange.month => '${start.day}',
    AnalyticsRange.allTime => _months[start.month - 1],
  };

  /// Shows every label for short ranges, but only every 5th day of a
  /// month and every 2nd month, so labels never overlap.
  int get _labelEvery => switch (summary.range) {
    AnalyticsRange.month => 5,
    AnalyticsRange.allTime => 2,
    _ => 1,
  };

  @override
  Widget build(BuildContext context) {
    final points = summary.revenuePoints;
    final lastIndex = points.length - 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue recovered',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.rwf(summary.revenue),
                style: AppTextStyles.headline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 160,
              child: LineChart(
                duration: AnimationConstants.pageTransition,
                curve: AnimationConstants.pageCurve,
                LineChartData(
                  minY: 0,
                  minX: 0,
                  maxX: lastIndex.toDouble(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          final isShown =
                              index >= 0 &&
                              index <= lastIndex &&
                              (index % _labelEvery == 0 || index == lastIndex);
                          if (!isShown) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _labelFor(points[index].start),
                              style: AppTextStyles.caption.copyWith(
                                color: index == lastIndex
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var index = 0; index <= lastIndex; index++)
                          FlSpot(
                            index.toDouble(),
                            points[index].amount.toDouble(),
                          ),
                      ],
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
