import 'constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/health_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/health_records/presentation/add_record_screen.dart';
import 'features/health_records/presentation/record_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = HealthProvider();
  await provider.init();
  runApp(
    ChangeNotifierProvider.value(value: provider, child: const HealthMateApp()),
  );
}

class HealthMateApp extends StatefulWidget {
  const HealthMateApp({super.key});

  @override
  State<HealthMateApp> createState() => _HealthMateAppState();
}

class _HealthMateAppState extends State<HealthMateApp> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    RecordListScreen(),
    AddRecordScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.primary,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: Scaffold(
        extendBody: true,
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: _buildModernNavBar(),
      ),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAnimatedNavItem(
            index: 0,
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          _buildAnimatedNavItem(
            index: 1,
            icon: Icons.assignment_rounded,
            label: 'Records',
          ),
          _buildAnimatedNavItem(
            index: 2,
            icon: Icons.add_circle_rounded,
            label: 'Add',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuad,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: isSelected ? 26 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
