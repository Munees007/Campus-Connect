import 'package:campus_connect/Components/toast_message.dart';
import 'package:campus_connect/Components/web_view_component.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageStaff extends StatefulWidget {
  const ManageStaff({super.key});

  @override
  State<ManageStaff> createState() => _ManageStaffState();
}

class _ManageStaffState extends State<ManageStaff> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child("users");
  List<Map<String, dynamic>> staffMembers = [];
  bool isLoading = true; // Track loading state
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  void _fetchStaff() async {
    _database.orderByChild("role").equalTo("staff").once().then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      setState(() {
        isLoading = false;
        staffMembers = data != null
            ? data.entries
                .where((entry) => (entry.value as Map)['staffId'] != 'ADMIN')
                .map((entry) => Map<String, dynamic>.from(entry.value as Map))
                .toList()
            : [];
      });
    });
  }

  void _addStaff(String name, String email, String department) {
    String staffId = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> newStaff = {
      "staffId": staffId,
      "name": name,
      "email": email,
      "department": department,
      "role": "staff",
    };

    _database.child(staffId).set(newStaff).then((_) {
      setState(() {
        staffMembers.add(newStaff);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Staff $name added"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void _deleteStaff(String staffId) {
    _database.orderByChild("staffId").equalTo(staffId).once().then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.keys.forEach((key) {
          _database.child(key).remove().then((_) {
            setState(() {
              staffMembers.removeWhere((staff) => staff["staffId"] == staffId);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Staff $staffId deleted"),
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

  void _updateStaff(String staffId, String name, String email) {
    if (staffId.isEmpty || name.isEmpty || email.isEmpty) {
      ToastManager().showToast(
          context: context, message: "Invalid Data", type: ToastType.warning);
      return;
    }
    _database.orderByChild("staffId").equalTo(staffId).once().then((event) {
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
            for (var staff in staffMembers) {
              if (staff["staffId"] == staffId) {
                staff["name"] = name;
                staff["email"] = email;
                break;
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Staff $staffId updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        });
      } else {
        ToastManager().showToast(
            context: context,
            message: "Something Went Wrong",
            type: ToastType.error);
        return;
      }
    });
  }

  void _showEditDialog(Map<String, dynamic> staff) {
    TextEditingController nameController =
        TextEditingController(text: staff["name"]);
    TextEditingController emailController =
        TextEditingController(text: staff["email"]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23233A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Staff",
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
                _updateStaff(staff["staffId"], name, email);
                setState(() {
                  staff["name"] = name;
                  staff["email"] = email;
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

  void _showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController departmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23233A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Staff",
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
              TextField(
                controller: departmentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Department",
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
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    departmentController.text.isNotEmpty) {
                  _addStaff(nameController.text, emailController.text,
                      departmentController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
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
    final filteredStaffs = staffMembers.where((student) {
      final name = student['name'].toString().toLowerCase();
      final email = student['email'].toString().toLowerCase();
      final rollNo = student['staffId'].toString().toLowerCase();
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
                          "Staff Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WebViewPage(
                                        title: "Add Staff",
                                        url:
                                            "https://staff-registration-grievpoint.netlify.app")));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Staff"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Staff Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WebViewPage(
                                        title: "Add Staff",
                                        url:
                                            "https://staff-registration-grievpoint.netlify.app")));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Staff"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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
                hintText: 'Search by name, email, or Staff Id',
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
              : filteredStaffs.isEmpty
                  ? const Center(
                      child: Text("No staff members found",
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Expanded(
                      child: isWideScreen
                          ? GridView.builder(
                              itemCount: filteredStaffs.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) =>
                                  _buildStaffCard(filteredStaffs[index]),
                            )
                          : ListView.builder(
                              itemCount: filteredStaffs.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    _buildStaffCard(filteredStaffs[
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

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    IconData genderIcon =
        staff["gender"] == "male" ? Icons.person : Icons.person_rounded;

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
                    "${staff["staffId"]} - ${staff["name"]}", // Staff ID included before name
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Department: ${staff["department"]}",
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
                Text("Email: ${staff["email"]}",
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
