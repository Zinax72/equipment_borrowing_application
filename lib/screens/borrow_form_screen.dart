import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/date_format.dart';
import '../widgets/app_text_field.dart';
import '../widgets/campus_primary_button.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/review_row.dart';
import '../widgets/section_title.dart';

class BorrowFormScreen extends StatefulWidget {
  final Map<String, int> selectedEquipment;
  final void Function(String name, int quantity) onQuantityChanged;
  final VoidCallback onSubmitted;

  const BorrowFormScreen({
    super.key,
    required this.selectedEquipment,
    required this.onQuantityChanged,
    required this.onSubmitted,
  });

  @override
  State<BorrowFormScreen> createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateNeededController = TextEditingController();
  final _returnDateController = TextEditingController();
  final _purposeController = TextEditingController();
  final _picker = ImagePicker();

  late final Stream<List<Equipment>> _equipmentStream = FirestoreService()
      .equipmentStream();

  DateTime? _dateNeeded;
  DateTime? _returnDate;
  Uint8List? _imageBytes;
  bool _submitting = false;

  String get _selectedEquipmentSummary => widget.selectedEquipment.entries
      .map(
        (entry) =>
            entry.value > 1 ? '${entry.key} × ${entry.value}' : entry.key,
      )
      .join(', ');

  int get _selectedUnitCount => widget.selectedEquipment.values.fold<int>(
    0,
    (total, quantity) => total + quantity,
  );

  @override
  void dispose() {
    _dateNeededController.dispose();
    _returnDateController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDateNeeded() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNeeded ?? _today,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      _dateNeeded = picked;
      _dateNeededController.text = formatDate(picked);
      // Return date can't be before the new date needed.
      if (_returnDate != null && _returnDate!.isBefore(picked)) {
        _returnDate = null;
        _returnDateController.clear();
      }
    });
  }

  Future<void> _pickReturnDate() async {
    if (_dateNeeded == null) {
      _showMessage('Pick the date needed first.');
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _dateNeeded!,
      firstDate: _dateNeeded!,
      lastDate: _dateNeeded!.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      _returnDate = picked;
      _returnDateController.text = formatDate(picked);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Small + compressed so it fits inside a Firestore document.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 50,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.length > 500 * 1024) {
        _showMessage('That photo is too large. Try a smaller one.');
        return;
      }
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _showMessage('Could not open the camera or gallery on this device.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Review your request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewRow(label: 'Equipment', value: _selectedEquipmentSummary),
                ReviewRow(
                  label: 'Date needed',
                  value: _dateNeededController.text,
                ),
                ReviewRow(
                  label: 'Return date',
                  value: _returnDateController.text,
                ),
                ReviewRow(
                  label: 'Purpose',
                  value: _purposeController.text.trim(),
                ),
                ReviewRow(
                  label: 'Photo',
                  value: _imageBytes == null ? 'None' : 'Attached',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Edit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnitCount == 0) {
      _showMessage('Add at least one item to your request.');
      return;
    }

    final confirmed = await _confirmDialog();
    if (!confirmed) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final photoBase64 = _imageBytes == null ? '' : base64Encode(_imageBytes!);

      final request = BorrowRequest(
        id: '',
        userId: user.uid,
        requesterName: user.displayName ?? '',
        email: user.email ?? '',
        equipment: widget.selectedEquipment.keys.toList(),
        equipmentQuantities: Map<String, int>.from(widget.selectedEquipment),
        purpose: _purposeController.text.trim(),
        dateNeeded: _dateNeeded!,
        returnDate: _returnDate!,
        photoBase64: photoBase64,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      final requestId = await FirestoreService().addRequest(request);

      await NotificationService.instance.showNow(
        requestId: requestId,
        title: 'Request submitted',
        body: '${request.equipmentSummary} is waiting for approval.',
      );
      await NotificationService.instance.scheduleReturnReminder(
        requestId: requestId,
        equipment: request.equipment,
        returnDate: request.returnDate,
      );

      if (!mounted) return;
      _resetForm();
      _showMessage('Request submitted!');
      widget.onSubmitted();
    } catch (e) {
      _showMessage('Could not submit the request. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _dateNeededController.clear();
    _returnDateController.clear();
    _purposeController.clear();
    setState(() {
      _dateNeeded = null;
      _returnDate = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SectionTitle(
              title: 'Borrow Request',
              subtitle: 'Choose equipment and fill in the details.',
            ),
            const SizedBox(height: 20),
            Text(
              'Equipment · $_selectedUnitCount selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Equipment>>(
              stream: _equipmentStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load equipment. Try again.');
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snapshot.data!
                    .where((e) => e.isAvailable)
                    .toList();
                final selectedItems = items
                    .where(
                      (item) => (widget.selectedEquipment[item.name] ?? 0) > 0,
                    )
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: items.map((item) {
                        final quantity =
                            widget.selectedEquipment[item.name] ?? 0;
                        final selected = quantity > 0;
                        return FilterChip(
                          label: Text(
                            selected ? '${item.name} · $quantity' : item.name,
                          ),
                          selected: selected,
                          backgroundColor: AppColors.field,
                          selectedColor: AppColors.coralWash,
                          checkmarkColor: AppColors.universityRed,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.universityRed
                                : AppColors.darkText,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (isSelected) => widget.onQuantityChanged(
                            item.name,
                            isSelected ? 1 : 0,
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedItems.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...selectedItems.map((item) {
                        final quantity =
                            widget.selectedEquipment[item.name] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.darkText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              QuantityStepper(
                                quantity: quantity,
                                maximum: item.available,
                                onChanged: (nextQuantity) => widget
                                    .onQuantityChanged(item.name, nextQuantity),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _dateNeededController,
              readOnly: true,
              onTap: _pickDateNeeded,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Pick a date' : null,
              decoration: const InputDecoration(
                labelText: 'Date needed',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _returnDateController,
              readOnly: true,
              onTap: _pickReturnDate,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Pick a date' : null,
              decoration: const InputDecoration(
                labelText: 'Return date',
                prefixIcon: Icon(Icons.event_available_outlined),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _purposeController,
              label: 'Purpose',
              hint: 'What will you use it for?',
              icon: Icons.notes_outlined,
              maxLines: 3,
              maxLength: 200,
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Please describe the purpose (at least 5 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 6),
            const Text(
              'Photo (optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_imageBytes == null)
              FilledButton.tonalIcon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Choose a photo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.field,
                  foregroundColor: AppColors.darkText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _imageBytes!,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _imageBytes = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            CampusPrimaryButton(
              label: 'Submit request',
              onPressed: _submitting ? null : _submit,
              loading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}
