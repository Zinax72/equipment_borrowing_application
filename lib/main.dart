import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RGOEquipmentApp());
}

class RGOEquipmentApp extends StatelessWidget {
  const RGOEquipmentApp({super.key});

  static const Color universityRed = Color(0xFFB71C1C);
  static const Color brightRed = Color(0xFFD32F2F);
  static const Color softYellow = Color(0xFFFFF8E1);
  static const Color gold = Color(0xFFFFC107);
  static const Color darkText = Color(0xFF242424);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RGO Equipment Borrowing',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: universityRed,
          primary: universityRed,
          secondary: gold,
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: universityRed, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brightRed, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brightRed, width: 2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

enum RequestStatus { pending, approved, borrowed, returned }

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.borrowed:
        return 'Borrowed';
      case RequestStatus.returned:
        return 'Returned';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFA000);
      case RequestStatus.approved:
        return const Color(0xFF1976D2);
      case RequestStatus.borrowed:
        return const Color(0xFF7B1FA2);
      case RequestStatus.returned:
        return const Color(0xFF2E7D32);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFF3E0);
      case RequestStatus.approved:
        return const Color(0xFFE3F2FD);
      case RequestStatus.borrowed:
        return const Color(0xFFF3E5F5);
      case RequestStatus.returned:
        return const Color(0xFFE8F5E9);
    }
  }
}

class Equipment {
  final String name;
  final String category;
  final int available;
  final IconData icon;
  final String description;
  final String imageUrl;

  const Equipment({
    required this.name,
    required this.category,
    required this.available,
    required this.icon,
    required this.description,
    required this.imageUrl,
  });
}

class BorrowRequest {
  final String organization;
  final String requester;
  final String email;
  final String contact;
  final String purpose;
  final String date;
  final String returnDate;
  final List<String> equipment;
  RequestStatus status;

  BorrowRequest({
    required this.organization,
    required this.requester,
    required this.email,
    required this.contact,
    required this.purpose,
    required this.date,
    required this.returnDate,
    required this.equipment,
    this.status = RequestStatus.pending,
  });
}

const List<Equipment> equipmentList = [
  Equipment(
    name: 'Projector',
    category: 'Audio-Visual',
    available: 5,
    icon: Icons.videocam_outlined,
    description:
    'Portable projector for presentations, seminars, meetings, and events.',
    imageUrl:
    'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=600',
  ),
  Equipment(
    name: 'Laptop',
    category: 'Computing',
    available: 8,
    icon: Icons.laptop_mac_outlined,
    description:
    'University laptop for presentations, workshops, and organization activities.',
    imageUrl:
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600',
  ),
  Equipment(
    name: 'Microphone',
    category: 'Audio',
    available: 12,
    icon: Icons.mic_none_outlined,
    description: 'Wired microphone for programs, meetings, and campus events.',
    imageUrl:
    'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=600',
  ),
  Equipment(
    name: 'Speaker',
    category: 'Audio',
    available: 6,
    icon: Icons.speaker_group_outlined,
    description: 'Portable speaker system for university programs and events.',
    imageUrl:
    'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600',
  ),
  Equipment(
    name: 'Extension Cord',
    category: 'Electrical',
    available: 15,
    icon: Icons.power_outlined,
    description: 'Extension cord for approved university activities.',
    imageUrl:
    'https://images.unsplash.com/photo-1601999009162-25d5f4d3f4b8?w=600',
  ),
  Equipment(
    name: 'HDMI Cable',
    category: 'Accessories',
    available: 10,
    icon: Icons.cable_outlined,
    description:
    'HDMI cable for connecting laptops, projectors, and displays.',
    imageUrl:
    'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        onBorrowPressed: () {
          changePage(1);
        },
        onViewAllPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EquipmentInventoryPage(),
            ),
          );
        },
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: toggleEquipment,
        approvalCount: submittedRequests
            .where((r) => r.status == RequestStatus.pending)
            .length,
      ),
      BorrowFormPage(
        selectedEquipment: selectedEquipment,
        onEquipmentChanged: toggleEquipment,
        onSubmitted: submitRequest,
      ),
      RequestsPage(
        requests: submittedRequests,
        onCancelRequest: cancelRequest,
        onCancelAllRequests: cancelAllRequests,
        onUpdateStatus: updateRequestStatus,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RGO Equipment Borrowing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: RGOEquipmentApp.universityRed,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Borrowing History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BorrowingHistoryPage(
                    requests: submittedRequests,
                  ),
                ),
              );
            },
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BorrowingHistoryPage(
                requests: submittedRequests,
              ),
            ),
          );
        },
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changePage,
        selectedItemColor: RGOEquipmentApp.universityRed,
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

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenHistory;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: RGOEquipmentApp.universityRed,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: RGOEquipmentApp.universityRed,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'RGO Equipment\nBorrowing System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            selected: currentIndex == 0,
            onTap: () => onNavigate(0),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Borrow Equipment'),
            selected: currentIndex == 1,
            onTap: () => onNavigate(1),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Request History'),
            selected: currentIndex == 2,
            onTap: () => onNavigate(2),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Borrowing History'),
            subtitle: const Text('Completed transactions'),
            onTap: onOpenHistory,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('About Me'),
            subtitle: const Text('Student developer'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: RGOEquipmentApp.universityRed,
                        ),
                        SizedBox(width: 8),
                        Text('About Me'),
                      ],
                    ),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: RGOEquipmentApp.softYellow,
                              child: Icon(
                                Icons.person,
                                size: 45,
                                color: RGOEquipmentApp.universityRed,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'RENDELLE AEZAKIMAK VICTORIA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Center(
                            child: Text(
                              'CICT BSIT Student',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'About this project',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This application is created to help Student Leaders and Organizations. It aims to improve the process of borrowing university equipment through a simple and organized RGO system.',
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('RGO Services'),
            subtitle: Text('University equipment management'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final VoidCallback onBorrowPressed;
  final VoidCallback onViewAllPressed;
  final List<String> selectedEquipment;
  final ValueChanged<String> onEquipmentChanged;
  final int approvalCount;

  const DashboardPage({
    super.key,
    required this.onBorrowPressed,
    required this.onViewAllPressed,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    required this.approvalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: RGOEquipmentApp.universityRed,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipment made easier.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Request university equipment through a simple and organized RGO system.',
                        style: TextStyle(color: Colors.white, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: onBorrowPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RGOEquipmentApp.gold,
                          foregroundColor: RGOEquipmentApp.darkText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                        child: const Text(
                          'Start Borrowing',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 70,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Quick Overview',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: SummaryCard(
                  title: 'Available',
                  value: '56',
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'For Approval',
                  value: '$approvalCount',
                  icon: Icons.pending_actions_outlined,
                  iconColor: RGOEquipmentApp.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Equipment',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onViewAllPressed,
                child: const Text('View all'),
              ),
            ],
          ),
          ListView.builder(
            itemCount: equipmentList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = equipmentList[index];
              return EquipmentCard(
                equipment: item,
                selected: selectedEquipment.contains(item.name),
                onTap: () => onEquipmentChanged(item.name),
              );
            },
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RGOEquipmentApp.softYellow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RGOEquipmentApp.gold.withOpacity(.55),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: RGOEquipmentApp.universityRed,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ready to request equipment? Continue to the borrowing form.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: onBorrowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EquipmentInventoryPage extends StatefulWidget {
  const EquipmentInventoryPage({super.key});

  @override
  State<EquipmentInventoryPage> createState() =>
      _EquipmentInventoryPageState();
}

class _EquipmentInventoryPageState extends State<EquipmentInventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Equipment> get _filteredEquipment {
    if (_searchQuery.trim().isEmpty) return equipmentList;
    final q = _searchQuery.toLowerCase();
    return equipmentList.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();
  }

  void showEquipmentDetails(Equipment equipment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(equipment.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      equipment.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: RGOEquipmentApp.softYellow,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: RGOEquipmentApp.universityRed,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: RGOEquipmentApp.softYellow,
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: RGOEquipmentApp.universityRed,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: RGOEquipmentApp.softYellow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        equipment.icon,
                        color: RGOEquipmentApp.universityRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        equipment.category,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(equipment.description),
                const SizedBox(height: 18),
                const Text(
                  'Availability',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('${equipment.available} units available'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredEquipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Inventory'),
        backgroundColor: RGOEquipmentApp.universityRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search equipment by name, category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
            ),
          ),
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No equipment found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Try a different keyword.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final equipment = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Image.network(
                                equipment.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    color: RGOEquipmentApp.softYellow,
                                    child: const Center(
                                      child: Icon(
                                        Icons
                                            .image_not_supported_outlined,
                                        size: 40,
                                        color: RGOEquipmentApp
                                            .universityRed,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: RGOEquipmentApp.softYellow,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: RGOEquipmentApp
                                              .universityRed,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: RGOEquipmentApp.softYellow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  equipment.icon,
                                  color: RGOEquipmentApp.universityRed,
                                  size: 29,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipment.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      equipment.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${equipment.available} available',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            equipment.description,
                            style: const TextStyle(
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showEquipmentDetails(equipment);
                              },
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('View Details'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                RGOEquipmentApp.universityRed,
                                side: const BorderSide(
                                  color: RGOEquipmentApp.universityRed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final bool selected;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: selected ? RGOEquipmentApp.softYellow : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? RGOEquipmentApp.gold
              : const Color(0xFFE5E5E5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: RGOEquipmentApp.universityRed.withOpacity(.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            equipment.icon,
            color: RGOEquipmentApp.universityRed,
          ),
        ),
        title: Text(
          equipment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${equipment.category} • ${equipment.available} available',
        ),
        trailing: IconButton(
          onPressed: onTap,
          icon: Icon(
            selected ? Icons.check_circle : Icons.add_circle_outline,
            color: selected ? Colors.green : RGOEquipmentApp.universityRed,
          ),
        ),
      ),
    );
  }
}

class BorrowFormPage extends StatefulWidget {
  final List<String> selectedEquipment;
  final ValueChanged<String> onEquipmentChanged;
  final ValueChanged<BorrowRequest> onSubmitted;

  const BorrowFormPage({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    required this.onSubmitted,
  });

  @override
  State<BorrowFormPage> createState() => _BorrowFormPageState();
}

class _BorrowFormPageState extends State<BorrowFormPage> {
  final _formKey = GlobalKey<FormState>();

  final organizationController = TextEditingController();
  final requesterController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final purposeController = TextEditingController();

  String selectedDate = 'Select date';
  String selectedReturnDate = 'Select return date';

  @override
  void dispose() {
    organizationController.dispose();
    requesterController.dispose();
    emailController.dispose();
    contactController.dispose();
    purposeController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Invalid email. Enter a complete email address.';
    }
    return null;
  }

  String? validateContact(String? value) {
    final contact = value?.trim() ?? '';
    if (contact.isEmpty) return 'Contact number is required.';
    if (!RegExp(r'^\d{11}$').hasMatch(contact)) {
      return 'Contact number must contain exactly 11 digits.';
    }
    return null;
  }

  Future<void> chooseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (picked != null) {
      setState(() {
        selectedDate = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> chooseReturnDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        selectedReturnDate = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  void clearForm() {
    organizationController.clear();
    requesterController.clear();
    emailController.clear();
    contactController.clear();
    purposeController.clear();
    setState(() {
      selectedDate = 'Select date';
      selectedReturnDate = 'Select return date';
    });
  }

  void submitForm() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: RGOEquipmentApp.brightRed,
          content: Text('Please correct the highlighted fields.'),
        ),
      );
      return;
    }

    if (widget.selectedEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: RGOEquipmentApp.brightRed,
          content: Text('Please select at least one equipment item.'),
        ),
      );
      return;
    }

    if (selectedDate == 'Select date') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: RGOEquipmentApp.brightRed,
          content: Text('Please select the borrowing date.'),
        ),
      );
      return;
    }

    if (selectedReturnDate == 'Select return date') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: RGOEquipmentApp.brightRed,
          content: Text('Please select the return date.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: RGOEquipmentApp.universityRed,
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Review Request')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewRow(
                  label: 'Organization',
                  value: organizationController.text,
                ),
                ReviewRow(
                  label: 'Requester',
                  value: requesterController.text,
                ),
                ReviewRow(label: 'Email', value: emailController.text),
                ReviewRow(label: 'Contact', value: contactController.text),
                ReviewRow(label: 'Borrowing Date', value: selectedDate),
                ReviewRow(
                  label: 'Return Date',
                  value: selectedReturnDate,
                ),
                ReviewRow(
                  label: 'Equipment',
                  value: widget.selectedEquipment.join(', '),
                ),
                ReviewRow(
                  label: 'Purpose',
                  value: purposeController.text,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                final request = BorrowRequest(
                  organization: organizationController.text,
                  requester: requesterController.text,
                  email: emailController.text,
                  contact: contactController.text,
                  purpose: purposeController.text,
                  date: selectedDate,
                  returnDate: selectedReturnDate,
                  equipment: List<String>.from(widget.selectedEquipment),
                );
                Navigator.pop(dialogContext);
                widget.onSubmitted(request);
                clearForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Request confirmed and submitted to RGO.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: RGOEquipmentApp.softYellow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: RGOEquipmentApp.gold.withOpacity(.5),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: RGOEquipmentApp.universityRed,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fill out the request details. Invalid inputs will be highlighted in red.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              title: 'Organization Information',
              subtitle:
              'Provide the details of the organization and requester.',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: organizationController,
              label: 'Organization Name',
              hint: 'e.g., Student Organization',
              icon: Icons.groups_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Organization name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: requesterController,
              label: 'Requester Name',
              hint: 'Full name of representative',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Requester name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: contactController,
              label: 'Contact Number',
              hint: '11 digits only',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validateContact,
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              title: 'Borrowing Details',
              subtitle:
              'Choose the equipment and provide the activity details.',
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Equipment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.selectedEquipment.isEmpty)
                      const Text(
                        'No equipment selected yet.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.selectedEquipment.map((item) {
                          return Chip(
                            label: Text(item),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              widget.onEquipmentChanged(item);
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (sheetContext) {
                            return SafeArea(
                              child: ListView(
                                padding: const EdgeInsets.all(18),
                                children: [
                                  const Text(
                                    'Available Equipment',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...equipmentList.map((equipment) {
                                    final selected = widget
                                        .selectedEquipment
                                        .contains(equipment.name);
                                    return CheckboxListTile(
                                      value: selected,
                                      activeColor:
                                      RGOEquipmentApp.universityRed,
                                      title: Text(equipment.name),
                                      subtitle: Text(
                                        '${equipment.available} available',
                                      ),
                                      onChanged: (_) {
                                        widget.onEquipmentChanged(
                                          equipment.name,
                                        );
                                        Navigator.pop(sheetContext);
                                      },
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add equipment'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month_outlined,
                  color: RGOEquipmentApp.universityRed,
                ),
                title: const Text(
                  'Borrowing Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(selectedDate),
                trailing: ElevatedButton(
                  onPressed: chooseDate,
                  child: const Text('Choose'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.event_available_outlined,
                  color: RGOEquipmentApp.universityRed,
                ),
                title: const Text(
                  'Return Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(selectedReturnDate),
                trailing: ElevatedButton(
                  onPressed: chooseReturnDate,
                  child: const Text('Choose'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: purposeController,
              label: 'Purpose / Activity',
              hint: 'Explain why the equipment is needed',
              icon: Icons.event_note_outlined,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'Please provide a short purpose (at least 10 characters).';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: submitForm,
                icon: const Icon(Icons.send_outlined),
                label: const Text(
                  'Submit Borrowing Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'The request will be reviewed by the RGO.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, height: 1.3),
        ),
      ],
    );
  }
}

class ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const ReviewRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class RequestsPage extends StatelessWidget {
  final List<BorrowRequest> requests;
  final ValueChanged<int> onCancelRequest;
  final VoidCallback onCancelAllRequests;
  final void Function(int index, RequestStatus status) onUpdateStatus;

  const RequestsPage({
    super.key,
    required this.requests,
    required this.onCancelRequest,
    required this.onCancelAllRequests,
    required this.onUpdateStatus,
  });

  void showCancelConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: RGOEquipmentApp.universityRed,
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Cancel Request?')),
            ],
          ),
          content: const Text(
            'Are you sure you want to cancel this borrowing request? The request will be removed from your request history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep Request'),
            ),
            ElevatedButton(
              onPressed: () {
                onCancelRequest(index);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Request cancelled and removed successfully.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showCancelAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.delete_sweep_outlined,
                color: RGOEquipmentApp.brightRed,
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Cancel All Requests?')),
            ],
          ),
          content: Text(
            'You currently have ${requests.length} active borrowing request${requests.length == 1 ? '' : 's'}. Are you sure you want to cancel all of them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep Requests'),
            ),
            ElevatedButton(
              onPressed: () {
                onCancelAllRequests();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'All borrowing requests have been cancelled.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showStatusChanger(
      BuildContext context,
      int index,
      RequestStatus current,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Request Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: RequestStatus.values.map((status) {
              return RadioListTile<RequestStatus>(
                value: status,
                groupValue: current,
                activeColor: RGOEquipmentApp.universityRed,
                title: Text(status.label),
                onChanged: (value) {
                  if (value != null) {
                    onUpdateStatus(index, value);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Status updated to ${value.label}.'),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void showRequestDetails(BuildContext context, BorrowRequest request) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewRow(
                  label: 'Organization',
                  value: request.organization,
                ),
                ReviewRow(label: 'Requester', value: request.requester),
                ReviewRow(label: 'Email', value: request.email),
                ReviewRow(label: 'Contact', value: request.contact),
                ReviewRow(label: 'Borrowing Date', value: request.date),
                ReviewRow(label: 'Return Date', value: request.returnDate),
                ReviewRow(
                  label: 'Equipment',
                  value: request.equipment.join(', '),
                ),
                ReviewRow(label: 'Purpose', value: request.purpose),
                ReviewRow(label: 'Status', value: request.status.label),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: RGOEquipmentApp.softYellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 42,
                  color: RGOEquipmentApp.universityRed,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No requests yet',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Submitted borrowing requests will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'My Requests',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showCancelAllConfirmation(context),
                icon: const Icon(Icons.delete_sweep_outlined, size: 19),
                label: const Text('Cancel All'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RGOEquipmentApp.brightRed,
                  side: const BorderSide(
                    color: RGOEquipmentApp.brightRed,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${requests.length} active request${requests.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...List.generate(requests.length, (index) {
            final request = requests[index];

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 14),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Borrowing Request',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showStatusChanger(
                            context,
                            index,
                            request.status,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: request.status.bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  request.status.label,
                                  style: TextStyle(
                                    color: request.status.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: request.status.color,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      request.organization,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Requester: ${request.requester}'),
                    Text('Date: ${request.date}'),
                    Text('Return: ${request.returnDate}'),
                    Text(
                      'Equipment: ${request.equipment.join(', ')}',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                showRequestDetails(context, request),
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('View'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                showCancelConfirmation(context, index),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              RGOEquipmentApp.brightRed,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BorrowingHistoryPage extends StatelessWidget {
  final List<BorrowRequest> requests;

  const BorrowingHistoryPage({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final history = requests
        .where((r) => r.status == RequestStatus.returned)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
        backgroundColor: RGOEquipmentApp.universityRed,
        foregroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: RGOEquipmentApp.softYellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.history,
                  size: 42,
                  color: RGOEquipmentApp.universityRed,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No borrowing history yet',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Completed (returned) transactions will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final request = history[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Completed Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: RequestStatus.returned.bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          RequestStatus.returned.label,
                          style: TextStyle(
                            color: RequestStatus.returned.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  Text(
                    request.organization,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Requester: ${request.requester}'),
                  Text('Borrowed: ${request.date}'),
                  Text('Returned: ${request.returnDate}'),
                  Text(
                    'Equipment: ${request.equipment.join(', ')}',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Purpose: ${request.purpose}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}