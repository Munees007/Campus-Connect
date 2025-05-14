import 'package:campus_connect/Pages/login_page.dart';
import 'package:campus_connect/Types/user_type.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String role = "";
  late Staff staff;
  late Student student;
  late String year;
  String getStudentYear(int joinedYear) {
    final now = DateTime.now();
    int currentYear = now.year;

    // If current month is before June, academic year hasn’t started yet
    if (now.month < 6) {
      currentYear -= 1;
    }

    int diff = currentYear - joinedYear;

    if (diff == 0) return "I YEAR";
    if (diff == 1) return "II YEAR";
    if (diff == 2) return "III YEAR";
    return "ALUMNI";
  }

  @override
  void initState() {
    super.initState();
    var userBox = Hive.box('userBox').get('userData');
    role = userBox['role'];
    if (role == 'staff') {
      staff = Staff.fromMap(userBox);
    } else {
      student = Student.fromMap(userBox);
      year = getStudentYear(student.joinedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  _buildProfileDetails(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              (role == 'staff' ? staff.name : student.name)
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          role == 'staff' ? staff.name : student.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Text(
            (role == "student" ? year + " " : "") +
                ((role == "staff" && staff.staffId == "ADMIN")
                    ? "PRINCIPAL"
                    : role.toUpperCase()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          _infoRow(
            Icons.school,
            "Department",
            role == 'staff' ? staff.department : student.department,
          ),
          const SizedBox(height: 15),
          _infoRow(
            Icons.email,
            "Email",
            role == 'staff' ? staff.email : student.email,
          ),
          const SizedBox(height: 15),
          if (role == 'staff')
            _infoRow(Icons.work, "Position", staff.position)
          else
            _infoRow(Icons.numbers, "Roll No", student.rollNo),
          if (role == 'staff') ...[
            const SizedBox(height: 15),
            _infoRow(Icons.badge, "Staff ID", staff.staffId),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blueAccent,
          size: 22,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Hive.box('userBox').clear();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: const Text(
          "Logout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
