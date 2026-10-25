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
import '../widgets/review_row.dart';
import '../widgets/section_title.dart';

class BorrowFormScreen extends StatefulWidget {
  final List<String> selectedEquipment;
  final ValueChanged<String> onEquipmentChanged;
  final VoidCallback onSubmitted;

  const BorrowFormScreen({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
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
                ReviewRow(
                  label: 'Equipment',
                  value: widget.selectedEquipment.join(', '),
                ),
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
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
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
    if (widget.selectedEquipment.isEmpty) {
      _showMessage('Select at least one equipment.');
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
        equipment: List<String>.from(widget.selectedEquipment),
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
        body: '${request.equipment.join(', ')} is waiting for approval.',
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
            const Text(
              'Equipment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Equipment>>(
              stream: _equipmentStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snapshot.data!
                    .where((e) => e.isAvailable)
                    .toList();
                return Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: items.map((item) {
                    return FilterChip(
                      label: Text(item.name),
                      selected: widget.selectedEquipment.contains(item.name),
                      selectedColor: AppColors.softYellow,
                      checkmarkColor: AppColors.universityRed,
                      onSelected: (_) => widget.onEquipmentChanged(item.name),
                    );
                  }).toList(),
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
              OutlinedButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Attach a photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.universityRed,
                  minimumSize: const Size.fromHeight(48),
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
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.universityRed,
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
