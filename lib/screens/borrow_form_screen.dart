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
import '../widgets/equipment_image.dart';
import '../widgets/glass_panel.dart';
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

  late final Stream<List<Equipment>> _equipmentStream =
      FirestoreService().equipmentStream();

  int _currentStep = 0;
  DateTime? _dateNeeded;
  DateTime? _returnDate;
  Uint8List? _imageBytes;
  bool _submitting = false;

  static const List<String> _purposePresets = [
    'Classroom Presentation',
    'Laboratory Exercise',
    'Student Org Event',
    'Thesis / Capstone Defense',
    'Campus Seminar Coverage',
  ];

  String get _selectedEquipmentSummary => widget.selectedEquipment.entries
      .map(
        (entry) =>
            entry.value > 1 ? '${entry.key} \u00D7 ${entry.value}' : entry.key,
      )
      .join(', ');

  int get _selectedUnitCount => widget.selectedEquipment.values.fold<int>(
        0,
        (total, quantity) => total + quantity,
      );

  int get _distinctItemCount => widget.selectedEquipment.length;

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
      if (_returnDate != null && _returnDate!.isBefore(picked)) {
        _returnDate = null;
        _returnDateController.clear();
      }
    });
  }

  Future<void> _pickReturnDate() async {
    if (_dateNeeded == null) {
      _showMessage('Select the date needed first.');
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
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassPanel(
              borderRadius: 26,
              blur: 24,
              opacity: 0.90,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'Attach supporting photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.universityRed,
                    ),
                    title: const Text('Take a photo'),
                    subtitle: const Text('Capture ID, room permit, or setup'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.universityRed,
                    ),
                    title: const Text('Choose from gallery'),
                    subtitle: const Text('Select an existing image'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_selectedUnitCount == 0) {
        _showMessage('Add at least one item to your Borrowing Basket first.');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_dateNeeded == null || _returnDate == null) {
        _showMessage('Please choose both the date needed and return date.');
        return;
      }
      if (_purposeController.text.trim().length < 5) {
        _showMessage('Please describe the purpose (at least 5 characters).');
        return;
      }
      setState(() => _currentStep = 2);
    }
  }

  Future<bool> _confirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Finalize Borrowing?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewRow(
                  label: 'Request List',
                  value: _selectedEquipmentSummary,
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
                  label: 'Attachment',
                  value: _imageBytes == null ? 'None' : 'Photo attached',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (_selectedUnitCount == 0) {
      _showMessage('Add at least one item to your Borrowing Basket.');
      setState(() => _currentStep = 0);
      return;
    }
    if (_dateNeeded == null ||
        _returnDate == null ||
        _purposeController.text.trim().length < 5) {
      _showMessage('Complete the schedule and purpose details first.');
      setState(() => _currentStep = 1);
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
        title: 'Batch Request Submitted',
        body: '${request.equipmentSummary} is awaiting custodian review.',
      );
      await NotificationService.instance.scheduleReturnReminder(
        requestId: requestId,
        equipment: request.equipment,
        returnDate: request.returnDate,
      );

      if (!mounted) return;
      _resetForm();
      _showMessage('Batch borrowing request submitted!');
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
      _currentStep = 0;
      _dateNeeded = null;
      _returnDate = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          children: [
            const SectionTitle(
              title: 'Borrowing Basket',
              subtitle:
                  'Curate your equipment request list, schedule dates, and finalize borrowing.',
            ),
            const SizedBox(height: 20),

            _GlassStepHeader(
              currentStep: _currentStep,
              basketCount: _selectedUnitCount,
              onStepTapped: (step) {
                if (step < _currentStep) {
                  setState(() => _currentStep = step);
                } else if (step == 1 && _selectedUnitCount > 0) {
                  setState(() => _currentStep = 1);
                } else if (step == 2 &&
                    _selectedUnitCount > 0 &&
                    _dateNeeded != null &&
                    _returnDate != null &&
                    _purposeController.text.trim().length >= 5) {
                  setState(() => _currentStep = 2);
                } else {
                  _goToNextStep();
                }
              },
            ),
            const SizedBox(height: 22),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildStepBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildBasketStep(context);
      case 1:
        return _buildScheduleStep(context);
      default:
        return _buildFinalizeStep(context);
    }
  }

  Widget _buildBasketStep(BuildContext context) {
    return StreamBuilder<List<Equipment>>(
      key: const ValueKey('step-0-basket'),
      stream: _equipmentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not load equipment. Try again.');
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final allItems = snapshot.data!;
        final availableItems = allItems.where((e) => e.isAvailable).toList();
        final selectedItems = allItems
            .where((item) => (widget.selectedEquipment[item.name] ?? 0) > 0)
            .toList();
        final unselectedItems = availableItems
            .where((item) => (widget.selectedEquipment[item.name] ?? 0) == 0)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REQUEST LIST \u00B7 $_distinctItemCount ${_distinctItemCount == 1 ? 'ITEM' : 'ITEMS'} ($_selectedUnitCount UNITS)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: AppColors.universityRed,
                  ),
                ),
                if (selectedItems.isNotEmpty)
                  Text(
                    'Swipe left to remove',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                          fontSize: 11.5,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (selectedItems.isEmpty)
              GlassPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                borderRadius: 24,
                opacity: 0.68,
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        color: AppColors.universityRed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Borrowing Basket is empty',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap any equipment below or from the Catalog to build your batch request.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              )
            else
              ...selectedItems.map((item) {
                final quantity = widget.selectedEquipment[item.name] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('basket-item-${item.name}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      final previousQty = quantity;
                      widget.onQuantityChanged(item.name, 0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Removed ${item.name} from Borrowing Basket',
                          ),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: AppColors.brightGold,
                            onPressed: () => widget.onQuantityChanged(
                              item.name,
                              previousQty,
                            ),
                          ),
                        ),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.maroonRuby, AppColors.brightRed],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 22,
                      opacity: 0.78,
                      child: Row(
                        children: [
                          EquipmentImage(
                            imageUrl: item.imageUrl,
                            width: 60,
                            height: 60,
                            radius: 14,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                    color: AppColors.universityRed,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: AppColors.darkText,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.available} available in stock',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.mutedText,
                                        fontSize: 11.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            compact: true,
                            quantity: quantity,
                            maximum: item.available,
                            onChanged: (nextQuantity) => widget
                                .onQuantityChanged(item.name, nextQuantity),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 18),

            if (unselectedItems.isNotEmpty) ...[
              Text(
                'ADD MORE EQUIPMENT TO REQUEST LIST',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unselectedItems.map((item) {
                  return GestureDetector(
                    onTap: () => widget.onQuantityChanged(item.name, 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 16,
                            color: AppColors.universityRed,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            CampusPrimaryButton(
              label: 'Continue to Schedule & Purpose',
              icon: Icons.arrow_forward_rounded,
              onPressed: _selectedUnitCount > 0 ? _goToNextStep : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleStep(BuildContext context) {
    final loanDays = (_dateNeeded != null && _returnDate != null)
        ? _returnDate!.difference(_dateNeeded!).inDays + 1
        : null;

    return Column(
      key: const ValueKey('step-1-schedule'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          opacity: 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BORROWING SCHEDULE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: AppColors.universityRed,
                    ),
                  ),
                  if (loanDays != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$loanDays-${loanDays == 1 ? 'day' : 'days'} window',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.universityRed,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dateNeededController,
                readOnly: true,
                onTap: _pickDateNeeded,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Pick a date' : null,
                decoration: const InputDecoration(
                  labelText: 'Date needed',
                  hintText: 'Select pickup date',
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
                  hintText: 'Select return date',
                  prefixIcon: Icon(Icons.event_available_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GlassPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          opacity: 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ACADEMIC OR EVENT PURPOSE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.universityRed,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _purposePresets.map((preset) {
                  final isSelected = _purposeController.text.trim() == preset;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _purposeController.text = preset;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.universityRed
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold.withValues(alpha: 0.6)
                              : AppColors.universityRed.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _purposeController,
                label: 'Purpose details',
                hint: 'Room number, course code, or campus organization event',
                icon: Icons.notes_rounded,
                maxLines: 3,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Please describe the purpose (at least 5 characters)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 0),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Basket'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.darkText,
                  side: BorderSide(
                    color: AppColors.darkText.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: CampusPrimaryButton(
                label: 'Continue to Finalize',
                icon: Icons.arrow_forward_rounded,
                onPressed: _goToNextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalizeStep(BuildContext context) {
    return Column(
      key: const ValueKey('step-2-finalize'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          opacity: 0.80,
          borderColor: AppColors.gold.withValues(alpha: 0.55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.universityRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Batch Request Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    child: const Text('Edit list'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReviewRow(
                label: 'Borrowing Basket',
                value: _selectedEquipmentSummary,
              ),
              ReviewRow(
                label: 'Schedule',
                value:
                    '${_dateNeededController.text} \u2192 ${_returnDateController.text}',
              ),
              ReviewRow(
                label: 'Purpose',
                value: _purposeController.text.trim(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GlassPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          opacity: 0.74,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SUPPORTING PHOTO (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.universityRed,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Attach a student ID, signed room permit, or activity memo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              const SizedBox(height: 14),
              if (_imageBytes == null)
                InkWell(
                  onTap: _showImageSourceSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.universityRed.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.universityRed,
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to capture or upload a photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        _imageBytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          tooltip: 'Remove photo',
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() => _imageBytes = null);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.darkText,
                  side: BorderSide(
                    color: AppColors.darkText.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: CampusPrimaryButton(
                label: 'Finalize Borrowing',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _submitting ? null : _submit,
                loading: _submitting,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassStepHeader extends StatelessWidget {
  final int currentStep;
  final int basketCount;
  final ValueChanged<int> onStepTapped;

  const _GlassStepHeader({
    required this.currentStep,
    required this.basketCount,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      (number: '1', label: 'Basket', icon: Icons.shopping_basket_outlined),
      (number: '2', label: 'Schedule', icon: Icons.event_outlined),
      (number: '3', label: 'Finalize', icon: Icons.task_alt_rounded),
    ];

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      borderRadius: 22,
      opacity: 0.82,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (idx) {
          if (idx.isOdd) {
            final beforeIdx = idx ~/ 2;
            final passed = beforeIdx < currentStep;
            return Container(
              width: 18,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: passed
                    ? AppColors.universityRed
                    : AppColors.darkText.withValues(alpha: 0.14),
              ),
            );
          }

          final stepIndex = idx ~/ 2;
          final active = stepIndex == currentStep;
          final completed = stepIndex < currentStep;
          final step = steps[stepIndex];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onStepTapped(stepIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.universityRed
                      : completed
                          ? AppColors.gold.withValues(alpha: 0.24)
                          : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active
                        ? AppColors.gold.withValues(alpha: 0.75)
                        : completed
                            ? AppColors.universityRed.withValues(alpha: 0.30)
                            : Colors.white.withValues(alpha: 0.85),
                    width: active ? 1.3 : 1.0,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color:
                                AppColors.universityRed.withValues(alpha: 0.24),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.brightGold
                            : completed
                                ? AppColors.universityRed
                                : AppColors.darkText.withValues(alpha: 0.10),
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                step.number,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: active
                                      ? AppColors.universityRed
                                      : AppColors.darkText,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        step.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: active || completed
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: active
                              ? Colors.white
                              : completed
                                  ? AppColors.universityRed
                                  : AppColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
