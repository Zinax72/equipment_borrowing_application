import 'package:flutter/material.dart';
import '../models/borrow_request.dart';

class BorrowFormScreen extends StatelessWidget {
  final List<String> selectedEquipment;
  final ValueChanged<String> onEquipmentChanged;
  final ValueChanged<BorrowRequest> onSubmitted;

  const BorrowFormScreen({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Borrow form: coming soon'));
  }
}
