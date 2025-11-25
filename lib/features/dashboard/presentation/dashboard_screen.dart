import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../providers/health_provider.dart';
import 'package:health_mate/constants/app_colors.dart';
import 'package:health_mate/widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context);
    final totals = hp.todayTotals();
    final avg = hp.last7DayAverages();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: hp.initialized == false
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Health Data...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with date
                      _buildHeader(context),
                      const SizedBox(height: 24),

                      // Today's Metrics Grid
                      _buildMetricsGrid(context, totals),
                      const SizedBox(height: 24),

                      // 7-day Averages Section
                      _buildAveragesSection(context, avg),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getFormattedDate(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Your health at a glance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Map<String, int?> totals) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedMetricCard(
                        title: 'Steps',
                        value: totals['steps']?.toString() ?? '0',
                        unit: 'steps',
                        icon: Icons.directions_walk_rounded,
                        color: AppColors.steps,
                        progress: (totals['steps'] ?? 0).toDouble(),
                        maxValue: 10000,
                        maxWidth: constraints.maxWidth / 2 - 8,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnimatedMetricCard(
                        title: 'Cals',
                        value: totals['calories']?.toString() ?? '0',
                        unit: 'kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.calories,
                        progress: (totals['calories'] ?? 0).toDouble(),
                        maxValue: 3000,
                        maxWidth: constraints.maxWidth / 2 - 8,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAnimatedMetricCard(
              title: 'Water',
              value: totals['water']?.toString() ?? '0',
              unit: 'ml',
              icon: Icons.water_drop_rounded,
              color: AppColors.water,
              progress: (totals['water'] ?? 0).toDouble(),
              maxValue: 3000,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
    required double maxValue,
    bool isFullWidth = false,
    double? maxWidth,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.0, end: progress / maxValue),
        builder: (context, animationValue, child) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            child: MetricCard(
              title: title,
              value: value,
              unit: unit,
              icon: icon,
              color: color,
              progress: progress,
              maxValue: maxValue,
              isFullWidth: isFullWidth,
              animationValue: animationValue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAveragesSection(BuildContext context, Map<String, double?> avg) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '7-day Averages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAverageGrid(avg),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageGrid(Map<String, double?> avg) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildAverageItem(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                value: avg['stepsAvg']?.toStringAsFixed(0) ?? '0',
                color: AppColors.steps,
                maxWidth: constraints.maxWidth / 3,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceVariant),
            Expanded(
              child: _buildAverageItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                value: avg['caloriesAvg']?.toStringAsFixed(0) ?? '0',
                color: AppColors.calories,
                maxWidth: constraints.maxWidth / 3,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceVariant),
            Expanded(
              child: _buildAverageItem(
                icon: Icons.water_drop_rounded,
                label: 'Water',
                value: '${avg['waterAvg']?.toStringAsFixed(0) ?? '0'} ml',
                color: AppColors.water,
                maxWidth: constraints.maxWidth / 3,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAverageItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$month/$day/${now.year}';
  }
}
