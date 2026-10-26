import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/equipment_image.dart';
import '../widgets/quantity_stepper.dart';
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
  late final Stream<List<Equipment>> _stream = FirestoreService()
      .equipmentStream();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Equipment> _filter(List<Equipment> all) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((equipment) {
      return equipment.name.toLowerCase().contains(query) ||
          equipment.category.toLowerCase().contains(query) ||
          equipment.description.toLowerCase().contains(query);
    }).toList();
  }

  void _openDetails(Equipment equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentDetailsScreen(
          equipment: equipment,
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
      appBar: AppBar(title: const Text('Equipment')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search equipment',
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
            Expanded(
              child: StreamBuilder<List<Equipment>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Could not load equipment.'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = _filter(snapshot.data!);
                  if (items.isEmpty) return _EmptyCatalog(query: _query);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760
                          ? 4
                          : constraints.maxWidth >= 520
                          ? 3
                          : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, index) {
                          final equipment = items[index];
                          return _EquipmentTile(
                            equipment: equipment,
                            quantity:
                                widget.selectedEquipment[equipment.name] ?? 0,
                            onQuantityChanged: (quantity) => widget
                                .onQuantityChanged(equipment.name, quantity),
                            onTap: () => _openDetails(equipment),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onTap;

  const _EquipmentTile({
    required this.equipment,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    final availabilityColor = equipment.isAvailable
        ? AppColors.green
        : AppColors.mutedText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.coralWash : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? AppColors.universityRed : Colors.transparent,
          width: selected ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: selected ? AppColors.coralWash : Colors.white,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Semantics(
                  button: true,
                  label:
                      '${equipment.name}, ${equipment.category}, ${equipment.isAvailable ? '${equipment.available} available' : 'unavailable'}',
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        EquipmentImage(imageUrl: equipment.imageUrl, radius: 0),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              child: Text(
                                equipment.isAvailable
                                    ? '${equipment.available} available'
                                    : 'Unavailable',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: availabilityColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.universityRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: onTap,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(48, 48),
                            ),
                            child: const Text('Details'),
                          ),
                          const Spacer(),
                          if (selected)
                            QuantityStepper(
                              quantity: quantity,
                              maximum: equipment.available,
                              onChanged: onQuantityChanged,
                            )
                          else
                            IconButton(
                              tooltip: 'Add ${equipment.name} to request',
                              onPressed: equipment.isAvailable
                                  ? () => onQuantityChanged(1)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.universityRed,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'No equipment listed yet' : 'No matches found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              query.isEmpty
                  ? 'Check back later for available equipment.'
                  : 'Try another equipment name or category.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
