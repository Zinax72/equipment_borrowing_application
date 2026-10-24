import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
        backgroundColor: AppColors.universityRed,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Equipment list: coming next')),
    );
  }
}
