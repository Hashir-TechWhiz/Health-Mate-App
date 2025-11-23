import 'package:flutter/material.dart';

void main() {
  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('HealthMate App', style: TextStyle(fontSize: 22)),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
