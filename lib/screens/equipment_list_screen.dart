import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/campus_backdrop.dart';
import '../widgets/equipment_card.dart';
import '../widgets/glass_panel.dart';
import 'equipment_details_screen.dart';

class EquipmentListScreen extends StatefulWidget {
  final ValueChanged<Equipment> onBorrow;
  final Map<String, int> selectedEquipment;
  final void Function(String name, int quantity) onQuantityChanged;

  const EquipmentListScreen({
    super.key,
    required this.onBorrow,
    required this.selectedEquipment,
    required this.onQuantityChanged,
  });

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final _searchController = TextEditingController();
  late final Stream<List<Equipment>> _stream =
      FirestoreService().equipmentStream();
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _basketCount => widget.selectedEquipment.values.fold<int>(
        0,
        (sum, q) => sum + q,
      );

  List<Equipment> _filter(List<Equipment> all) {
    final query = _query.trim().toLowerCase();
    return all.where((equipment) {
      final matchesCategory = _selectedCategory == 'All' ||
          equipment.category.trim() == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          equipment.name.toLowerCase().contains(query) ||
          equipment.category.toLowerCase().contains(query) ||
          equipment.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openDetails(Equipment equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentDetailsScreen(
          equipment: equipment,
          initialQuantity: widget.selectedEquipment[equipment.name] ?? 0,
          onQuantityChanged: (qty) {
            setState(() {
              widget.onQuantityChanged(equipment.name, qty);
            });
          },
          onBorrow: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            widget.onBorrow(equipment);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
        title: Text(
          'Equipment Catalog',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
                letterSpacing: -0.4,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Badge(
                isLabelVisible: _basketCount > 0,
                backgroundColor: AppColors.universityRed,
                label: Text(
                  '$_basketCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                child: IconButton(
                  tooltip: 'Borrowing Basket',
                  icon: const Icon(Icons.shopping_basket_outlined),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackdrop()),
          SafeArea(
            child: StreamBuilder<List<Equipment>>(
              stream: _stream,
              builder: (context, snapshot) {
                final allItems = snapshot.data ?? [];
                final categories = <String>{
                  'All',
                  ...allItems
                      .map((e) => e.category.trim())
                      .where((c) => c.isNotEmpty),
                }.toList();

                final items = _filter(allItems);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        borderRadius: 20,
                        blur: 18,
                        opacity: 0.75,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText:
                                'Search by equipment name, category, or use...',
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    if (categories.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final selected = category == _selectedCategory;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.universityRed
                                        : Colors.white.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.gold
                                              .withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.darkText,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    Expanded(
                      child: snapshot.hasError
                          ? const Center(
                              child: Text('Could not load equipment.'),
                            )
                          : !snapshot.hasData
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : items.isEmpty
                                  ? _EmptyCatalog(query: _query)
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final columns =
                                            constraints.maxWidth >= 760
                                                ? 4
                                                : constraints.maxWidth >= 520
                                                    ? 3
                                                    : 2;

                                        return GridView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            4,
                                            20,
                                            28,
                                          ),
                                          itemCount: items.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 14,
                                            mainAxisSpacing: 14,
                                            childAspectRatio: 0.69,
                                          ),
                                          itemBuilder: (context, index) {
                                            final equipment = items[index];
                                            return EquipmentCard(
                                              equipment: equipment,
                                              quantity: widget.selectedEquipment[
                                                      equipment.name] ??
                                                  0,
                                              onQuantityChanged: (quantity) {
                                                setState(() {
                                                  widget.onQuantityChanged(
                                                    equipment.name,
                                                    quantity,
                                                  );
                                                });
                                              },
                                              onTap: () =>
                                                  _openDetails(equipment),
                                            );
                                          },
                                        );
                                      },
                                    ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  final String query;

  const _EmptyCatalog({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassPanel(
          padding: const EdgeInsets.all(28),
          borderRadius: 24,
          opacity: 0.70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppColors.universityRed,
              ),
              const SizedBox(height: 12),
              Text(
                query.isEmpty ? 'No equipment listed yet' : 'No matches found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                query.isEmpty
                    ? 'Check back later for available campus equipment.'
                    : 'Try another equipment name or category filter.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
