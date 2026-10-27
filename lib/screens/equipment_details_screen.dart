import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import '../widgets/campus_backdrop.dart';
import '../widgets/campus_primary_button.dart';
import '../widgets/equipment_image.dart';
import '../widgets/glass_panel.dart';
import '../widgets/quantity_stepper.dart';

// Detailed view for a single piece of equipment with specs and quantity selector.
class EquipmentDetailsScreen extends StatefulWidget {
  final Equipment equipment;
  final VoidCallback onBorrow;
  final int initialQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const EquipmentDetailsScreen({
    super.key,
    required this.equipment,
    required this.onBorrow,
    this.initialQuantity = 0,
    this.onQuantityChanged,
  });

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  // Generates a readable BulSU asset tag (e.g. BULSU-AUD-601) from category and name.
  String get _assetCode {
    final prefix = widget.equipment.category.isNotEmpty
        ? widget.equipment.category
              .replaceAll(RegExp(r'[^A-Za-z]'), '')
              .toUpperCase()
        : 'AST';
    final shortPrefix = prefix.length >= 3
        ? prefix.substring(0, 3)
        : prefix.padRight(3, 'X');
    final hash = widget.equipment.name.codeUnits
        .fold<int>(0, (a, b) => a + b)
        .toString()
        .padLeft(3, '0');
    return 'BULSU-$shortPrefix-$hash';
  }

  // Saves the chosen quantity into the Borrowing Basket and returns to the catalog.
  void _handleAddToRequest() {
    if (widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(_quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${widget.equipment.name} (\u00D7$_quantity) to Borrowing Basket',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      widget.onBorrow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.equipment;
    final availabilityColor = equipment.isAvailable
        ? AppColors.green
        : AppColors.mutedText;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColoredBox(color: Colors.white.withValues(alpha: 0.45)),
          ),
        ),
        title: Text(
          'Asset Specifications',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackdrop()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 28,
                        blur: 20,
                        opacity: 0.72,
                        child: Stack(
                          children: [
                            Hero(
                              tag:
                                  'equipment-img-${equipment.id.isEmpty ? equipment.name : equipment.id}',
                              child: EquipmentImage(
                                imageUrl: equipment.imageUrl,
                                height: 260,
                                radius: 20,
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 12,
                                    sigmaY: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _assetCode,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.7,
                                        color: AppColors.universityRed,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Text(
                              equipment.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.universityRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: availabilityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: availabilityColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  equipment.isAvailable
                                      ? '${equipment.available} units available'
                                      : 'Currently unavailable',
                                  style: TextStyle(
                                    color: availabilityColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        equipment.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        'TECHNICAL & BORROWING SPECS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.85,
                        children: [
                          _SpecGlassTile(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Asset Identifier',
                            value: _assetCode,
                          ),
                          _SpecGlassTile(
                            icon: Icons.verified_user_outlined,
                            label: 'Condition',
                            value: 'Inspected \u00B7 Grade A',
                          ),
                          _SpecGlassTile(
                            icon: Icons.place_outlined,
                            label: 'Pickup Location',
                            value: 'BulSU Property Custodian',
                          ),
                          _SpecGlassTile(
                            icon: Icons.schedule_rounded,
                            label: 'Loan Policy',
                            value: 'Standard Batch Request',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        opacity: 0.62,
                        tintColor: AppColors.softYellow,
                        borderColor: AppColors.gold.withValues(alpha: 0.45),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.universityRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add multiple items to your Borrowing Basket to submit a single consolidated batch request.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.darkText,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    borderRadius: 26,
                    blur: 22,
                    opacity: 0.85,
                    child: Row(
                      children: [
                        if (equipment.isAvailable) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'QUANTITY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              QuantityStepper(
                                quantity: _quantity,
                                maximum: equipment.available,
                                onChanged: (val) {
                                  if (val >= 1) {
                                    setState(() => _quantity = val);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: CampusPrimaryButton(
                            icon: Icons.playlist_add_check_rounded,
                            label: equipment.isAvailable
                                ? (widget.initialQuantity > 0
                                      ? 'Update Request List'
                                      : 'Add to Request')
                                : 'Unavailable',
                            onPressed: equipment.isAvailable
                                ? _handleAddToRequest
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecGlassTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecGlassTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 18,
      opacity: 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.universityRed),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
