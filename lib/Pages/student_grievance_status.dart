import 'package:campus_connect/Pages/grievance_details_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StudentGrievanceStatus extends StatelessWidget {
  const StudentGrievanceStatus({super.key});

  @override
  Widget build(BuildContext context) {
    var userData = Hive.box('userBox').get('userData');
    String userId = userData['role'] == 'student'
        ? userData['rollNo']
        : userData['staffId'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref("grievances")
              .orderByChild("rollNoOrStaffId")
              .equalTo(userId)
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(
                child: Text(
                  "No grievances found!",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              );
            }

            Map<dynamic, dynamic> grievances =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              itemCount: grievances.length,
              itemBuilder: (context, index) {
                var grievance = grievances.entries.elementAt(index);
                String grievanceId = grievance.key;
                String title = grievance.value['title'];
                Map<dynamic, dynamic>? allowedStaff =
                    grievance.value['allowedStaff'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrievanceDetailPage(
                          grievanceId: grievanceId,
                          grievanceData: grievance.value,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
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
                        Text(
                          "📌 $title",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "👨‍🏫 Allowed Staff:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        _buildAllowedStaffList(context, allowedStaff),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Tap to view details ➡",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAllowedStaffList(
      BuildContext context, Map<dynamic, dynamic>? allowedStaff) {
    if (allowedStaff == null || allowedStaff.isEmpty) {
      return const Text(
        "No staff assigned.",
        style: TextStyle(color: Colors.redAccent),
      );
    }
    return Wrap(
      spacing: 8,
      children: allowedStaff.keys.map((staffId) {
        return GestureDetector(
          onTap: () => _showStaffDetailsPopup(context, staffId),
          child: Chip(
            label: Text(
              staffId,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showStaffDetailsPopup(BuildContext context, String staffId) {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Staff Details",
            style: TextStyle(color: Colors.white),
          ),
          content: StreamBuilder(
            stream: usersRef.onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Text(
                  "Staff details not found.",
                  style: TextStyle(color: Colors.white70),
                );
              }

              Map<dynamic, dynamic> usersData =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              Map<dynamic, dynamic>? staffData;
              for (var entry in usersData.entries) {
                if (entry.value['staffId'] == staffId) {
                  staffData = entry.value;
                  break;
                }
              }

              if (staffData == null) {
                return const Text(
                  "Staff details not found.",
                  style: TextStyle(color: Colors.white70),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _staffDetailRow("👨‍🏫 Name", staffData['name']),
                  _staffDetailRow("📧 Email", staffData['email']),
                  _staffDetailRow("📞 Department", staffData['department']),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _staffDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
