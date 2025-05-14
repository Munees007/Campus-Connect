import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageStudentsByStaff extends StatefulWidget {
  final String department, departmentType;
  const ManageStudentsByStaff(
      {super.key, required this.department, required this.departmentType});

  @override
  State<ManageStudentsByStaff> createState() => _ManageStudentsByStaffState();
}

class _ManageStudentsByStaffState extends State<ManageStudentsByStaff> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child("users");
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() async {
    _database.orderByChild("role").equalTo("student").once().then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          students = data.entries.where((entry) {
            final value = Map<String, dynamic>.from(entry.value as Map);
            return value['department'] == widget.department &&
                value['departmentType'] == widget.departmentType;
          }).map((entry) {
            return Map<String, dynamic>.from(entry.value as Map);
          }).toList();
        });
      } else {
        students = [];
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  void _deleteStudent(String rollNo) {
    _database.orderByChild("rollNo").equalTo(rollNo).once().then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.keys.forEach((key) {
          _database.child(key).remove().then((_) {
            setState(() {
              students.removeWhere((student) => student["rollNo"] == rollNo);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Student $rollNo deleted"),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          });
        });
      }
    });
  }

  void _updateStudent(String rollNO, String name, String email) {
    _database.orderByChild("rollNo").equalTo(rollNO).once().then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Get the correct Firebase-generated key
        String firebaseKey = data.keys.first;

        // Update only the specified fields
        _database.child(firebaseKey).update({
          "name": name,
          "email": email,
        }).then((_) {
          setState(() {
            for (var student in students) {
              if (student["rollNo"] == rollNO) {
                student["name"] = name;
                student["email"] = email;
                break;
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Staff $rollNO updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        });
      }
    });
  }

  void _showEditDialog(Map<String, dynamic> student) {
    TextEditingController nameController =
        TextEditingController(text: student["name"]);
    TextEditingController emailController =
        TextEditingController(text: student["email"]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23233A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Student",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String email = emailController.text;
                _updateStudent(student["rollNo"], name, email);
                setState(() {
                  student["name"] = name;
                  student["email"] = email;
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;
    final filteredStudents = students.where((student) {
      final name = student['name'].toString().toLowerCase();
      final email = student['email'].toString().toLowerCase();
      final rollNo = student['rollNo'].toString().toLowerCase();
      final department = student['department'].toString().toLowerCase();
      List<String> deptArr =
          student['departmentType'].toString().toLowerCase().split(' ');
      final level = deptArr[0];
      final type = deptArr[1];
      return name.contains(searchQuery) ||
          email.contains(searchQuery) ||
          rollNo.contains(searchQuery) ||
          department.contains(searchQuery) ||
          level.contains(searchQuery) ||
          type.contains(searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, constraints) {
              bool isNarrow =
                  constraints.maxWidth < 400; // you can adjust the threshold
              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Student Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => const WebViewPage(
                        //                 title: "Add Student",
                        //                 url:
                        //                     "https://student-registration-grievpoint.netlify.app")));
                        //   },
                        //   icon: const Icon(Icons.add),
                        //   label: const Text("Add Student"),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.blueAccent,
                        //     foregroundColor: Colors.white,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Student Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => const WebViewPage(
                        //                 title: "Add Student",
                        //                 url:
                        //                     "https://student-registration-grievpoint.netlify.app")));
                        //   },
                        //   icon: const Icon(Icons.add),
                        //   label: const Text("Add Student"),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.blueAccent,
                        //     foregroundColor: Colors.white,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or roll number',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF23233A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : filteredStudents.isEmpty
                  ? const Center(
                      child: Text("No students found",
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Expanded(
                      child: isWideScreen
                          ? GridView.builder(
                              itemCount: filteredStudents.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) =>
                                  _buildStudentCard(filteredStudents[index]),
                            )
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    _buildStudentCard(filteredStudents[
                                        index]), // Your card widget
                                    const SizedBox(
                                        height:
                                            12), // Adds spacing between cards
                                  ],
                                );
                              }),
                    ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    IconData genderIcon =
        student["gender"] == "male" ? Icons.person : Icons.person_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(genderIcon, color: Colors.white, size: 28), // Gender-based icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${student["rollNo"]} - ${student["name"]}", // Student ID included before name
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Department: ${student["department"]}",
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
                Text("Joined Year: ${student["joinedYear"]}",
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
                Text("Email: ${student["email"]}",
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditDialog(student),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () =>
                _showDeleteConfirmation(context, student["rollNo"]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String rollNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23233A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Text(
            "Confirm Deletion",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete Student ${rollNo}?",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement delete functionality
                Navigator.pop(context);
                _deleteStudent(rollNo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
