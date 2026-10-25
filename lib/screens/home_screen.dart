import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import 'borrow_form_screen.dart';
import 'dashboard_screen.dart';
import 'equipment_list_screen.dart';
import 'history_screen.dart';
import 'my_requests_screen.dart';
import 'dart:async';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final List<String> selectedEquipment = [];

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
                '${r.equipment.join(', ')} is now ${r.status.label.toLowerCase()}.',
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

  void toggleEquipment(String equipmentName) {
    setState(() {
      if (selectedEquipment.contains(equipmentName)) {
        selectedEquipment.remove(equipmentName);
      } else {
        selectedEquipment.add(equipmentName);
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
          onBorrow: (equipment) {
            if (!selectedEquipment.contains(equipment.name)) {
              toggleEquipment(equipment.name);
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
        title: const Text(
          'BorrowIT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.universityRed,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Borrowing History',
            icon: const Icon(Icons.history),
            onPressed: openHistory,
          ),
        ],
      ),
      drawer: AppDrawer(
        currentIndex: selectedIndex,
        onNavigate: (index) {
          Navigator.pop(context);
          changePage(index);
        },
        onOpenHistory: () {
          Navigator.pop(context);
          openHistory();
        },
      ),
      body: StreamBuilder<List<BorrowRequest>>(
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
                onEquipmentChanged: toggleEquipment,
                approvalCount: pendingCount,
              ),
              BorrowFormScreen(
                selectedEquipment: selectedEquipment,
                onEquipmentChanged: toggleEquipment,
                onSubmitted: onRequestSubmitted,
              ),
              const MyRequestsScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changePage,
        selectedItemColor: AppColors.universityRed,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Borrow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Requests',
          ),
        ],
      ),
    );
  }
}
