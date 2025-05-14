import 'package:campus_connect/Pages/chat_bot.dart';
import 'package:campus_connect/Pages/grievance_page.dart';
import 'package:campus_connect/Pages/grievance_view.dart';
import 'package:campus_connect/Pages/profile_page.dart';
import 'package:campus_connect/Pages/student_grievance_status.dart';
import 'package:campus_connect/Pages/user/circular_viewer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> pages;
  late List<BottomNavigationBarItem> bottomBarItems;
  late List<String> pageTitles;
  late List<IconData> pageIcons;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    String role = Hive.box('userBox').get('userData')['role'];
    String userId = role == "staff"
        ? Hive.box('userBox').get('userData')['staffId']
        : Hive.box('userBox').get('userData')['rollNo'];
    String depart = Hive.box('userBox').get('userData')['department'];
    List<String> deptArr = Hive.box('userBox')
        .get('userData')['departmentType']
        .toString()
        .split(' ');

    if (role == 'staff') {
      pages = [
        const ChatBot(),
        const GrievanceList(),
        CircularDisplayWidget(
          role: "staff",
          filterRole: "Teaching Staff Only",
          userId: userId,
          department: depart,
          type: deptArr[1],
          level: deptArr[0],
        ),
        const ProfilePage()
      ];
      pageTitles = ["Help Desk", "Assigned Grievances", "Circulars", "Profile"];
      pageIcons = [
        Icons.chat_bubble_outline,
        Icons.assignment_outlined,
        Icons.announcement_outlined,
        Icons.person_outline
      ];

      bottomBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: "Ask",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: "Grievances",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.announcement_outlined),
          activeIcon: Icon(Icons.announcement),
          label: "Circulars",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    } else {
      pages = [
        const ChatBot(),
        const GrievancePage(),
        CircularDisplayWidget(
            role: "student",
            filterRole: "Students Only",
            userId: userId,
            department: depart,
            type: deptArr[1],
            level: deptArr[0]),
        const StudentGrievanceStatus(),
        const ProfilePage()
      ];
      pageTitles = [
        "Help Desk",
        "Raise Grievance",
        "Circulars",
        "Grievance Status",
        "Profile"
      ];
      pageIcons = [
        Icons.chat_bubble_outline,
        Icons.add_comment_outlined,
        Icons.announcement_outlined,
        Icons.assignment_turned_in_outlined,
        Icons.person_outline
      ];

      bottomBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: "Ask",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_comment_outlined),
          activeIcon: Icon(Icons.add_comment),
          label: "Raise Issue",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.announcement_outlined),
          activeIcon: Icon(Icons.announcement),
          label: "Circulars",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in_outlined),
          activeIcon: Icon(Icons.assignment_turned_in),
          label: "Status",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: pages[currentPage],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                pageIcons[currentPage],
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                pageTitles[currentPage],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
          elevation: 0,
          items: bottomBarItems,
          currentIndex: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
        ),
      ),
    );
  }
}
