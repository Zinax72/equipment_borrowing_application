import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/borrowit_logo.dart';
import '../widgets/campus_backdrop.dart';
import 'borrow_form_screen.dart';
import 'dashboard_screen.dart';
import 'equipment_list_screen.dart';
import 'history_screen.dart';
import 'my_requests_screen.dart';

// Main shell screen holding the top AppBar, navigation drawer, 3 main tabs, and bottom nav bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Currently active bottom navigation tab (0 = Catalog, 1 = Basket, 2 = Requests).
  int selectedIndex = 0;
  // Shared Borrowing Basket state: maps equipment name -> selected quantity.
  final Map<String, int> selectedEquipment = {};

  final _firestore = FirestoreService();
  late Stream<List<Equipment>> _equipmentStream = _firestore.equipmentStream();
  late Stream<List<BorrowRequest>> _requestsStream = _firestore.requestsStream(
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );
  StreamSubscription<List<BorrowRequest>>? _statusSub;
  final Map<String, RequestStatus> _lastStatus = {};
  bool _firstSnapshot = true;

  @override
  void initState() {
    super.initState();
    // Seed sample equipment if Firestore collection is empty, and watch for request status changes.
    _firestore.seedEquipmentIfEmpty();
    _watchStatusChanges();
  }

  @override
  void reassemble() {
    super.reassemble();
    _equipmentStream = _firestore.equipmentStream();
    _requestsStream = _firestore.requestsStream(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    _statusSub?.cancel();
    _watchStatusChanges();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  // Total number of equipment units currently inside the Borrowing Basket.
  int get _basketUnitCount => selectedEquipment.values.fold<int>(
        0,
        (total, qty) => total + qty,
      );

  // Listens for status changes on the user's requests and triggers a local notification.
  void _watchStatusChanges() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _statusSub = _firestore.requestsStream(uid).listen((requests) {
      for (final r in requests) {
        final before = _lastStatus[r.id];
        if (!_firstSnapshot && before != null && before != r.status) {
          final reasonSuffix = r.status == RequestStatus.rejected &&
                  r.rejectionReason.trim().isNotEmpty
              ? ' Reason: ${r.rejectionReason.trim()}'
              : '';
          NotificationService.instance.showNow(
            requestId: r.id,
            title: 'Request ${r.status.label}',
            body:
                '${r.equipmentSummary} is now ${r.status.label.toLowerCase()}.$reasonSuffix',
          );
          if (r.status == RequestStatus.returned ||
              r.status == RequestStatus.rejected) {
            NotificationService.instance.cancelReminder(r.id);
          }
        }
        _lastStatus[r.id] = r.status;
      }
      _firstSnapshot = false;
    });
  }

  // Switches between the Catalog, Basket, and Requests tabs.
  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Adds, updates, or removes an item quantity in the Borrowing Basket.
  void setEquipmentQuantity(String equipmentName, int quantity) {
    setState(() {
      if (quantity <= 0) {
        selectedEquipment.remove(equipmentName);
      } else {
        selectedEquipment[equipmentName] = quantity;
      }
    });
  }

  // Clears the basket after submitting a request and jumps to the Requests tab.
  void onRequestSubmitted() {
    setState(() {
      selectedEquipment.clear();
      selectedIndex = 2;
    });
  }

  // Opens the Borrowing History Log screen.
  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  // Opens the full searchable Equipment Catalog screen.
  void openEquipmentList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentListScreen(
          selectedEquipment: selectedEquipment,
          onQuantityChanged: setEquipmentQuantity,
          onBorrow: (equipment) {
            final currentQuantity = selectedEquipment[equipment.name] ?? 0;
            if (currentQuantity < equipment.available) {
              setEquipmentQuantity(equipment.name, currentQuantity + 1);
            }
            changePage(1);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basketUnits = _basketUnitCount;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.62),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const BorrowItLogo(compact: true),
        leading: IconButton(
          tooltip: 'Open navigation menu',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => AppDrawer.show(
            context,
            currentIndex: selectedIndex,
            onNavigate: changePage,
            onOpenHistory: openHistory,
          ),
        ),
        actions: [
          Center(
            child: Badge(
              isLabelVisible: basketUnits > 0,
              backgroundColor: AppColors.universityRed,
              label: Text(
                '$basketUnits',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: IconButton(
                tooltip: 'Borrowing Basket',
                icon: Icon(
                  selectedIndex == 1
                      ? Icons.shopping_basket_rounded
                      : Icons.shopping_basket_outlined,
                  color: basketUnits > 0
                      ? AppColors.universityRed
                      : AppColors.darkText,
                ),
                onPressed: () => changePage(1),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Borrowing History Log',
            icon: const Icon(Icons.history_rounded),
            onPressed: openHistory,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackdrop()),
          StreamBuilder<List<BorrowRequest>>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              final pendingCount = (snapshot.data ?? [])
                  .where((r) => r.status == RequestStatus.pending)
                  .length;

              return IndexedStack(
                index: selectedIndex,
                children: [
                  DashboardScreen(
                    equipmentStream: _equipmentStream,
                    onBorrowPressed: () => changePage(1),
                    onViewAllPressed: openEquipmentList,
                    selectedEquipment: selectedEquipment,
                    onQuantityChanged: setEquipmentQuantity,
                    approvalCount: pendingCount,
                  ),
                  BorrowFormScreen(
                    selectedEquipment: selectedEquipment,
                    onQuantityChanged: setEquipmentQuantity,
                    onSubmitted: onRequestSubmitted,
                  ),
                  const MyRequestsScreen(),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.universityRed.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: changePage,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Catalog',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: basketUnits > 0,
                        backgroundColor: AppColors.universityRed,
                        label: Text('$basketUnits'),
                        child: const Icon(Icons.shopping_basket_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: basketUnits > 0,
                        backgroundColor: AppColors.universityRed,
                        label: Text('$basketUnits'),
                        child: const Icon(Icons.shopping_basket_rounded),
                      ),
                      label: 'Basket',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.timeline_outlined),
                      selectedIcon: Icon(Icons.timeline_rounded),
                      label: 'Requests',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
