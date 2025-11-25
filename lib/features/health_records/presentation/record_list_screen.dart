import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_record.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/health_provider.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  DateTimeRange? _filterRange;

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context);
    final records = hp.records;

    List<HealthRecord> visible = records;
    if (_filterRange != null) {
      visible = records.where((r) {
        return r.date.compareTo(
                  DateFormat('yyyy-MM-dd').format(_filterRange!.start),
                ) >=
                0 &&
            r.date.compareTo(
                  DateFormat('yyyy-MM-dd').format(_filterRange!.end),
                ) <=
                0;
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Health Records',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        actions: [
          // Filter Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: _filterRange != null
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              color: _filterRange != null ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_alt_rounded,
                color: _filterRange != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                  initialDateRange:
                      _filterRange ??
                      DateTimeRange(
                        start: now.subtract(const Duration(days: 6)),
                        end: now,
                      ),
                );
                if (picked != null) setState(() => _filterRange = picked);
              },
            ),
          ),
          // Clear Filter Button
          if (_filterRange != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.calories.withValues(alpha: 0.3),
                    AppColors.calories.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.clear_rounded, color: AppColors.calories),
                onPressed: () => setState(() => _filterRange = null),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.scaffoldBackground,
              AppColors.scaffoldBackground.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: RefreshIndicator(
          backgroundColor: AppColors.surface,
          color: AppColors.primary,
          onRefresh: () async => await hp.loadRecords(),
          child: visible.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final r = visible[idx];
                    return _buildModernRecordCard(r, context, hp);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceVariant.withValues(alpha: 0.3),
                  AppColors.surfaceVariant.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 60,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No records found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterRange != null
                ? 'Try adjusting your filter settings'
                : 'Add your first health record to get started',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernRecordCard(
    HealthRecord r,
    BuildContext context,
    HealthProvider hp,
  ) {
    final recordDate = DateTime.parse(r.date);
    final isToday =
        DateFormat('yyyy-MM-dd').format(recordDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dayOfWeek = DateFormat('EEE').format(recordDate);
    final month = DateFormat('MMM').format(recordDate);
    final day = DateFormat('d').format(recordDate);
    final today = DateTime.now();
    final isPast = recordDate.isBefore(
      DateTime(today.year, today.month, today.day),
    );

    return Dismissible(
      key: ValueKey(r.id),
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.3),
              Colors.red.withValues(alpha: 0.1),
            ],
            end: Alignment.centerRight,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (context) async {
        if (r.id != null) await hp.deleteRecord(r.id!);
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text(
              'Record deleted',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.primary,
              onPressed: () {},
            ),
          ),
        );
      },
      child: Opacity(
        opacity: isPast ? 0.65 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.9),
                AppColors.surfaceVariant.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                if (isPast) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surface,
                      content: Text(
                        "You can't edit past records",
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  );
                  return;
                }

                final edited = await showDialog<HealthRecord>(
                  context: context,
                  builder: (_) => _EditRecordDialog(record: r),
                );
                if (edited != null) await hp.updateRecord(edited);
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: isToday
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.8),
                                  AppColors.primary.withValues(alpha: 0.4),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.surfaceVariant,
                                  AppColors.surfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isToday
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            month.toUpperCase(),
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            day,
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            dayOfWeek,
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Metrics with Progress Indicators
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Steps with progress bar
                          _buildModernMetricRow(
                            icon: Icons.directions_walk_rounded,
                            value: r.steps,
                            maxValue: 10000,
                            color: AppColors.steps,
                            label: 'Steps',
                          ),
                          const SizedBox(height: 12),

                          // Calories with progress bar
                          _buildModernMetricRow(
                            icon: Icons.local_fire_department_rounded,
                            value: r.calories,
                            maxValue: 3000,
                            color: AppColors.calories,
                            label: 'Calories',
                          ),
                          const SizedBox(height: 12),

                          // Water with progress bar
                          _buildModernMetricRow(
                            icon: Icons.water_drop_rounded,
                            value: r.water,
                            maxValue: 3000,
                            color: AppColors.water,
                            label: 'Water',
                            unit: 'ml',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernMetricRow({
    required IconData icon,
    required int value,
    required int maxValue,
    required Color color,
    required String label,
    String unit = '',
  }) {
    final percentage = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$value${unit.isNotEmpty ? ' $unit' : ''}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                width: (percentage * 100).clamp(0.0, 100.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditRecordDialog extends StatefulWidget {
  final HealthRecord record;
  const _EditRecordDialog({required this.record});

  @override
  State<_EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<_EditRecordDialog> {
  late final TextEditingController stepsCtrl;
  late final TextEditingController calCtrl;
  late final TextEditingController waterCtrl;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    stepsCtrl = TextEditingController(text: widget.record.steps.toString());
    calCtrl = TextEditingController(text: widget.record.calories.toString());
    waterCtrl = TextEditingController(text: widget.record.water.toString());
    date = DateTime.parse(widget.record.date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Health Record',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Date Picker
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat.yMMMd().format(date),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Steps Input
                  _buildInputField(
                    controller: stepsCtrl,
                    label: 'Steps',
                    icon: Icons.directions_walk_rounded,
                    color: AppColors.steps,
                  ),
                  const SizedBox(height: 16),
                  // Calories Input
                  _buildInputField(
                    controller: calCtrl,
                    label: 'Calories',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.calories,
                  ),
                  const SizedBox(height: 16),
                  // Water Input
                  _buildInputField(
                    controller: waterCtrl,
                    label: 'Water',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.water,
                    unit: 'ml',
                  ),
                ],
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final updated = HealthRecord(
                          id: widget.record.id,
                          date: DateFormat('yyyy-MM-dd').format(date),
                          steps: int.tryParse(stepsCtrl.text) ?? 0,
                          calories: int.tryParse(calCtrl.text) ?? 0,
                          water: int.tryParse(waterCtrl.text) ?? 0,
                        );
                        Navigator.of(context).pop(updated);
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    String unit = '',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: '$label${unit.isNotEmpty ? ' ($unit)' : ''}',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: color),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
