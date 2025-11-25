import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_record.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/health_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final TextEditingController _stepsCtrl = TextEditingController();
  final TextEditingController _calCtrl = TextEditingController();
  final TextEditingController _waterCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Add Record',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Date',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMd().format(_date),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Steps Input
              _buildModernTextField(
                controller: _stepsCtrl,
                label: 'Steps',
                icon: Icons.directions_walk_rounded,
                color: AppColors.steps,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter valid steps';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories Input
              _buildModernTextField(
                controller: _calCtrl,
                label: 'Calories',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.calories,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter valid calories';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Water Input
              _buildModernTextField(
                controller: _waterCtrl,
                label: 'Water (ml)',
                icon: Icons.water_drop_rounded,
                color: AppColors.water,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter valid water';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;

                    final formattedDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(_date);

                    // Check if record already exists for today
                    final exists = hp.records.any(
                      (r) => r.date == formattedDate,
                    );
                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'A record for today already exists, try editing that record!',
                          ),
                        ),
                      );
                      return;
                    }

                    final rec = HealthRecord(
                      date: formattedDate,
                      steps: int.parse(_stepsCtrl.text),
                      calories: int.parse(_calCtrl.text),
                      water: int.parse(_waterCtrl.text),
                    );

                    await hp.addRecord(rec);

                    // RESET FORM AFTER SUCCESS
                    _formKey.currentState!.reset();
                    _stepsCtrl.clear();
                    _calCtrl.clear();
                    _waterCtrl.clear();
                    setState(() {
                      _date = DateTime.now();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Record saved successfully!'),
                      ),
                    );
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Save Record',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.calories, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.calories, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        keyboardType: TextInputType.number,
        validator: validator,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
