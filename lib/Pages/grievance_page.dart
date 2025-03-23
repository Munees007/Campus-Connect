import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:campus_connect/Components/toast_message.dart';

class GrievancePage extends StatefulWidget {
  const GrievancePage({super.key});

  @override
  State<GrievancePage> createState() => _GrievancePageState();
}

class _GrievancePageState extends State<GrievancePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  late String rollNoOrStaffId;
  late String email;
  List<String> selectedStaff = [];
  List<Map<String, String>> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    var userData = Hive.box('userBox').get('userData');
    rollNoOrStaffId =
        userData['role'] == 'staff' ? userData['staffId'] : userData['rollNo'];
    email = userData['email'];
    _fetchStaffList();
  }

  void _fetchStaffList() async {
    DatabaseReference staffRef = FirebaseDatabase.instance.ref("users");
    DataSnapshot snapshot = await staffRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        staffList = data.entries
            .where((entry) => entry.value['role'] == 'staff')
            .map((entry) => <String, String>{
                  "id": entry.value['staffId'].toString(),
                  "name": entry.value['name'].toString()
                })
            .toList();
        isLoading = false;
      });
    }
  }

  void _submitGrievance() async {
    if (_titleController.text.trim().isEmpty ||
        _detailsController.text.trim().isEmpty ||
        selectedStaff.isEmpty) {
      ToastManager().showToast(
          context: context,
          message: "Please fill in all fields!",
          type: ToastType.error);
      return;
    }

    DatabaseReference grievanceRef =
        FirebaseDatabase.instance.ref("grievances").push();

    await grievanceRef.set({
      'rollNoOrStaffId': rollNoOrStaffId,
      'email': email,
      'title': _titleController.text.trim(),
      'details': _detailsController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'allowedStaff': {for (var staffId in selectedStaff) staffId: true},
      'replies': {}
    });

    _titleController.clear();
    _detailsController.clear();
    selectedStaff.clear();
    setState(() {});

    ToastManager().showToast(
        context: context,
        message: "Grievance Submitted!",
        type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Submit Grievance",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 15),
              _buildTextField(_titleController, "Grievance Title"),
              const SizedBox(height: 10),
              _buildTextField(_detailsController, "Grievance Details",
                  maxLines: 3),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : _buildMultiSelect(),
              const SizedBox(height: 10),
              _buildSelectedChips(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitGrievance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildMultiSelect() {
    return GestureDetector(
      onTap: () async {
        List<String>? selected = await showDialog<List<String>>(
          context: context,
          builder: (BuildContext context) {
            List<String> tempSelection = List.from(selectedStaff);

            return AlertDialog(
              title: const Text("Select Staff"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: staffList.map((staff) {
                    return CheckboxListTile(
                      title: Text(staff['name']!),
                      value: tempSelection.contains(staff['id']),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            tempSelection.add(staff['id']!);
                          } else {
                            tempSelection.remove(staff['id']!);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempSelection),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        if (selected != null) {
          setState(() {
            selectedStaff = selected;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Staff",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          selectedStaff.isEmpty
              ? "Tap to select staff"
              : "${selectedStaff.length} staff selected",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
      spacing: 6,
      children: selectedStaff.map((staffId) {
        String staffName = staffList.firstWhere(
            (staff) => staff['id'] == staffId,
            orElse: () => {"name": "Unknown"})['name']!;
        return Chip(
          label: Text(staffName),
          backgroundColor: Colors.blueAccent,
          labelStyle: const TextStyle(color: Colors.white),
          onDeleted: () {
            setState(() => selectedStaff.remove(staffId));
          },
        );
      }).toList(),
    );
  }
}
