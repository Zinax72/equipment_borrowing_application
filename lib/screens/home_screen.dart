import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import 'borrow_form_screen.dart';
import 'dashboard_screen.dart';
import 'equipment_list_screen.dart';
import 'history_screen.dart';
import 'my_requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> selectedEquipment = [];
  final List<BorrowRequest> submittedRequests = [];

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

  void submitRequest(BorrowRequest request) {
    setState(() {
      submittedRequests.add(request);
      selectedEquipment.clear();
      selectedIndex = 2;
    });
  }

  void cancelRequest(int index) {
    setState(() {
      submittedRequests.removeAt(index);
    });
  }

  void cancelAllRequests() {
    setState(() {
      submittedRequests.clear();
    });
  }

  void updateRequestStatus(int index, RequestStatus newStatus) {
    setState(() {
      submittedRequests[index].status = newStatus;
    });
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(requests: submittedRequests),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        onBorrowPressed: () {
          changePage(1);
        },
        onViewAllPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EquipmentListScreen(),
            ),
          );
        },
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: toggleEquipment,
        approvalCount: submittedRequests
            .where((r) => r.status == RequestStatus.pending)
            .length,
      ),
      BorrowFormScreen(
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: toggleEquipment,
        onSubmitted: submitRequest,
      ),
      MyRequestsScreen(
        requests: submittedRequests,
        onCancelRequest: cancelRequest,
        onCancelAllRequests: cancelAllRequests,
        onUpdateStatus: updateRequestStatus,
      ),
    ];

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
      body: IndexedStack(index: selectedIndex, children: pages),
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
