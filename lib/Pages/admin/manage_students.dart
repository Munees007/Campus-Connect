import 'package:campus_connect/Components/web_view_component.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child("users");
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
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
          students = data.entries.map((entry) {
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.deepPurpleAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Student Management",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WebViewPage(
                                title: "Add Staff",
                                url:
                                    "https://student-registration-grievpoint.netlify.app")));
                  }, // Add student functionality later
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Student",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : students.isEmpty
                  ? const Center(
                      child: Text("No students found",
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Expanded(
                      child: isWideScreen
                          ? GridView.builder(
                              itemCount: students.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) =>
                                  _buildStudentCard(students[index]),
                            )
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    _buildStudentCard(
                                        students[index]), // Your card widget
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
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {}),
        ],
      ),
    );
  }
}

void _showDeleteConfirmation(BuildContext context, int index) {
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
          "Are you sure you want to delete Student ${2000 + index}?",
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Student ${2000 + index} deleted"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
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
