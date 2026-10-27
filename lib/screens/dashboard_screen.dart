import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import '../widgets/campus_primary_button.dart';
import '../widgets/equipment_card.dart';
import '../widgets/glass_panel.dart';
import '../widgets/summary_card.dart';
import 'equipment_details_screen.dart';

// Main catalog dashboard showing greeting, summary cards, category filters, and equipment grid.
class DashboardScreen extends StatefulWidget {
  final Stream<List<Equipment>> equipmentStream;
  final VoidCallback onBorrowPressed;
  final VoidCallback onViewAllPressed;
  final Map<String, int> selectedEquipment;
  final void Function(String name, int quantity) onQuantityChanged;
  final int approvalCount;

  const DashboardScreen({
    super.key,
    required this.equipmentStream,
    required this.onBorrowPressed,
    required this.onViewAllPressed,
    required this.selectedEquipment,
    required this.onQuantityChanged,
    required this.approvalCount,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'All';

  // Opens the EquipmentDetailsScreen when the user taps an equipment card.
  void _openDetails(BuildContext context, Equipment item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentDetailsScreen(
          equipment: item,
          initialQuantity: widget.selectedEquipment[item.name] ?? 0,
          onQuantityChanged: (qty) => widget.onQuantityChanged(item.name, qty),
          onBorrow: () {
            final current = widget.selectedEquipment[item.name] ?? 0;
            if (current == 0 && item.isAvailable) {
              widget.onQuantityChanged(item.name, 1);
            }
            Navigator.pop(context);
            widget.onBorrowPressed();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavClearance = MediaQuery.paddingOf(context).bottom;
    final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    final greetingName = displayName == null || displayName.isEmpty
        ? 'there'
        : displayName.split(RegExp(r'\s+')).first;

    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<Equipment>>(
        stream: widget.equipmentStream,
        builder: (context, snapshot) {
          final allItems = snapshot.data ?? [];
          final totalAvailable = allItems.fold<int>(
            0,
            (sum, item) => sum + item.available,
          );
          final selectedCount = widget.selectedEquipment.values.fold<int>(
            0,
            (sum, quantity) => sum + quantity,
          );

          final categories = <String>{
            'All',
            ...allItems
                .map((e) => e.category.trim())
                .where((c) => c.isNotEmpty),
          }.toList();

          final filteredItems = _selectedCategory == 'All'
              ? allItems
              : allItems
                    .where((e) => e.category.trim() == _selectedCategory)
                    .toList();

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  bottomNavClearance + (selectedCount > 0 ? 105 : 24),
                ),
                children: [
                  Text(
                    'Hello, $greetingName!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Curate your Borrowing Basket for lab, class, and campus events.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Top summary metrics: Available stock, items In Basket, and Pending requests.
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Available',
                          value: '$totalAvailable',
                          icon: Icons.inventory_2_outlined,
                          iconColor: AppColors.green,
                          onTap: widget.onViewAllPressed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          title: 'In Basket',
                          value: '$selectedCount',
                          icon: Icons.shopping_basket_outlined,
                          iconColor: AppColors.gold,
                          onTap: widget.onBorrowPressed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          title: 'Pending',
                          value: '${widget.approvalCount}',
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.universityRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Section header for the Equipment Catalog with "Explore all" button.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipment Catalog',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap any item for specs or add directly to your request list',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onViewAllPressed,
                        icon: const Icon(Icons.tune_rounded, size: 17),
                        label: const Text('Explore all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (categories.length > 1) ...[
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == _selectedCategory;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.universityRed,
                                          AppColors.maroonRuby,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.gold.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.85),
                                  width: 1.1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (snapshot.hasError)
                    const _CatalogMessage(
                      icon: Icons.wifi_off_outlined,
                      message:
                          'Could not load equipment. Check your connection.',
                    )
                  else if (!snapshot.hasData)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredItems.isEmpty)
                    const _CatalogMessage(
                      icon: Icons.inventory_2_outlined,
                      message: 'No equipment found in this category.',
                    )
                  else
                    GridView.builder(
                      itemCount: filteredItems.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.69,
                          ),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return EquipmentCard(
                          equipment: item,
                          quantity: widget.selectedEquipment[item.name] ?? 0,
                          onQuantityChanged: (quantity) =>
                              widget.onQuantityChanged(item.name, quantity),
                          onTap: () => _openDetails(context, item),
                        );
                      },
                    ),
                ],
              ),

              // Floating Borrowing Basket dock that appears when at least 1 item is selected.
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomNavClearance + 12,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: widget.selectedEquipment.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty-basket'))
                      : GlassPanel(
                          key: const ValueKey('active-basket'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          borderRadius: 24,
                          blur: 22,
                          opacity: 0.88,
                          borderColor: AppColors.universityRed.withValues(
                            alpha: 0.35,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_basket_outlined,
                                  color: AppColors.universityRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Borrowing Basket \u00B7 $selectedCount ${selectedCount == 1 ? 'unit' : 'units'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.darkText,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.selectedEquipment.entries
                                          .map(
                                            (entry) => entry.value > 1
                                                ? '${entry.key} \u00D7 ${entry.value}'
                                                : entry.key,
                                          )
                                          .join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.mutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CampusPrimaryButton(
                                compact: true,
                                label: 'Finalize',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: widget.onBorrowPressed,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CatalogMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      borderRadius: 24,
      opacity: 0.65,
      child: Column(
        children: [
          Icon(icon, color: AppColors.universityRed, size: 30),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
