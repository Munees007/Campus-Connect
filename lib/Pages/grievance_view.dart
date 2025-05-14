import 'package:campus_connect/Pages/grievance_details_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_database/firebase_database.dart';

class GrievanceList extends StatelessWidget {
  const GrievanceList({super.key});

  // Function to fetch user details
  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("users")
          .orderByChild("rollNo")
          .equalTo(userId)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
        // Return the first user found
        return Map<String, dynamic>.from(users.values.first);
      }

      // If not found by rollNo, try staffId
      final staffSnapshot = await FirebaseDatabase.instance
          .ref("users")
          .orderByChild("staffId")
          .equalTo(userId)
          .get();

      if (staffSnapshot.exists) {
        Map<dynamic, dynamic> users =
            staffSnapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(users.values.first);
      }

      return null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var userData = Hive.box('userBox').get('userData');
    String userId =
        userData['role'] == 'staff' ? userData['staffId'] : userData['rollNo'];

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
          stream: FirebaseDatabase.instance.ref("grievances").onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            Map<dynamic, dynamic> grievances =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            var filteredGrievances = grievances.entries.where((entry) {
              return entry.value['allowedStaff']?.containsKey(userId) ?? false;
            }).toList();

            if (filteredGrievances.isEmpty) {
              return const Center(
                child: Text(
                  "No grievances assigned to you.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              );
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Assigned Grievances",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredGrievances.length,
                      itemBuilder: (context, index) {
                        var grievance = filteredGrievances[index];
                        String grievanceId = grievance.key;
                        String submitterId =
                            grievance.value['rollNoOrStaffId'] ?? 'Unknown';

                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _fetchUserDetails(submitterId),
                          builder: (context, userSnapshot) {
                            // Default submitter info if data is still loading or not found
                            String submitterName = submitterId;
                            String submitterDept = "";

                            // Update with actual data if available
                            if (userSnapshot.hasData &&
                                userSnapshot.data != null) {
                              submitterName =
                                  userSnapshot.data!['name'] ?? submitterId;
                              submitterDept =
                                  userSnapshot.data!['department'] ?? "";
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GrievanceDetailPage(
                                          grievanceId: grievanceId,
                                          grievanceData: grievance.value,
                                        ),
                                      ),
                                    );
                                  },
                                  splashColor: Colors.white.withOpacity(0.1),
                                  highlightColor:
                                      Colors.white.withOpacity(0.05),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "📌 ${grievance.value['title']}",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.blueAccent,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          grievance.value['details'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Submitter info with user details
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: 14,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    submitterName,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Department tag if available
                                            if (submitterDept.isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purpleAccent
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.purpleAccent
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  submitterDept,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                            // Replies count
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (grievance.value['replies'] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.greenAccent
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.comment,
                                                  size: 14,
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${(grievance.value['replies'] as Map).length}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showStudentDetailsPopup(BuildContext context, String studentId) {
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              if (entry.value['rollNo'] == studentId) {
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
                _studentDetailRow("👨‍🏫 Name", staffData['rollNo']),
                _studentDetailRow("📧 Email", staffData['name']),
                _studentDetailRow("📞 Department", staffData['department']),
                _studentDetailRow("🎒 Batch", staffData['joinedYer']),
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

Widget _studentDetailRow(String label, String value) {
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
