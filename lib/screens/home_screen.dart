import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/borrowit_logo.dart';
import 'borrow_form_screen.dart';
import 'dashboard_screen.dart';
import 'equipment_list_screen.dart';
import 'history_screen.dart';
import 'my_requests_screen.dart';
import 'dart:async';
import 'dart:ui';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final Map<String, int> selectedEquipment = {};

  final _firestore = FirestoreService();
  late final Stream<List<Equipment>> _equipmentStream = _firestore
      .equipmentStream();
  late final Stream<List<BorrowRequest>> _requestsStream = _firestore
      .requestsStream(FirebaseAuth.instance.currentUser?.uid ?? '');
  StreamSubscription<List<BorrowRequest>>? _statusSub;
  final Map<String, RequestStatus> _lastStatus = {};
  bool _firstSnapshot = true;

  @override
  void initState() {
    super.initState();
    _firestore.seedEquipmentIfEmpty();
    _watchStatusChanges();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  // Notifies when a request's status changes (not on the first load).
  void _watchStatusChanges() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _statusSub = _firestore.requestsStream(uid).listen((requests) {
      for (final r in requests) {
        final before = _lastStatus[r.id];
        if (!_firstSnapshot && before != null && before != r.status) {
          NotificationService.instance.showNow(
            requestId: r.id,
            title: 'Request ${r.status.label}',
            body:
                '${r.equipmentSummary} is now ${r.status.label.toLowerCase()}.',
          );
          if (r.status == RequestStatus.returned) {
            NotificationService.instance.cancelReminder(r.id);
          }
        }
        _lastStatus[r.id] = r.status;
      }
      _firstSnapshot = false;
    });
  }

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void setEquipmentQuantity(String equipmentName, int quantity) {
    setState(() {
      if (quantity <= 0) {
        selectedEquipment.remove(equipmentName);
      } else {
        selectedEquipment[equipmentName] = quantity;
      }
    });
  }

  void onRequestSubmitted() {
    setState(() {
      selectedEquipment.clear();
      selectedIndex = 2;
    });
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: ColoredBox(color: AppColors.canvas.withValues(alpha: 0.72)),
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
          IconButton(
            tooltip: 'Borrowing History',
            icon: const Icon(Icons.history_rounded),
            onPressed: openHistory,
          ),
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
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkText.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: changePage,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.add_box_outlined),
                      selectedIcon: Icon(Icons.add_box_rounded),
                      label: 'Borrow',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded),
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
