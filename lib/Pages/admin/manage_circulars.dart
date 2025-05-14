import 'package:campus_connect/Pages/admin/circular_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ManageCirculars extends StatefulWidget {
  const ManageCirculars({super.key});

  @override
  State<ManageCirculars> createState() => _ManageCircularsState();
}

class _ManageCircularsState extends State<ManageCirculars> {
  final DatabaseReference _circularsRef =
      FirebaseDatabase.instance.ref().child('circulars');
  List<Map<String, dynamic>> circulars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCirculars();
  }

  Future<void> _loadCirculars() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _circularsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> loadedCirculars = [];

        data.forEach((key, value) {
          final circular = Map<String, dynamic>.from(value as Map);
          circular['id'] = key;
          loadedCirculars.add(circular);
        });

        // Sort by publish date (newest first)
        loadedCirculars.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          circulars = loadedCirculars;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading circulars: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isNarrow =
                  constraints.maxWidth < 400; // you can adjust the threshold
              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Circular Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddCircularDialog(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("New Circular"),
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
                          "Circular Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddCircularDialog(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("New Circular"),
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
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  )
                : circulars.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.announcement_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No circulars available",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showAddCircularDialog(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Create First Circular"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCirculars,
                        color: Colors.blueAccent,
                        child: ListView.builder(
                          itemCount: circulars.length,
                          itemBuilder: (context, index) {
                            final circular = circulars[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CircularDetailPage(
                                      circular: circular,
                                      role: "admin",
                                      userId: "admin",
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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
                                              circular['title'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue,
                                                    size: 20),
                                                onPressed: () {
                                                  _showEditCircularDialog(
                                                      context, circular);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red,
                                                    size: 20),
                                                onPressed: () {
                                                  _showDeleteConfirmation(
                                                      context, circular);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _buildCircularBadge(
                                            circular['category'],
                                            _getCategoryColor(
                                                circular['category']),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildCircularBadge(
                                            circular['department'] ??
                                                'All Departments',
                                            Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildCircularBadge(
                                            circular['audience'] ?? 'All',
                                            Colors.teal,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        circular['content'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Published: ${_formatDate(circular['createdAt'])}",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (circular['staffViewCount'] !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.visibility,
                                                  size: 16,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Staff: ${circular['staffViewCount']}",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (circular['studentViewCount'] !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.visibility,
                                                  size: 16,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Student: ${circular['studentViewCount']}",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Academic":
        return Colors.orange;
      case "Administrative":
        return Colors.green;
      case "Event":
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showAddCircularDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    String selectedCategory = "Academic";
    String selectedAudience = "All";
    String selectedLevel = "UG";
    String selectedType = "Aided";
    String selectedDepartment = "";

    List<String> departmentList = [];
    final audiences = ["All", "Students Only", "Teaching Staff Only"];

    // Initialize the toggle state for filtering
    bool isFilterByLevelAndType = true;

    DatabaseReference departmentsRef =
        FirebaseDatabase.instance.ref().child("departments");

    // Function to fetch departments based on Level and Type
    void fetchDepartments(Function(void Function()) setState) async {
      try {
        final snapshot =
            await departmentsRef.child("$selectedLevel/$selectedType").get();
        if (snapshot.exists) {
          List<dynamic> fetched = snapshot.value as List<dynamic>;
          setState(() {
            departmentList = List<String>.from(fetched);
            if (!departmentList.contains(selectedDepartment)) {
              selectedDepartment = departmentList.isNotEmpty
                  ? departmentList.first
                  : "Select Department";
            }
          });
        } else {
          setState(() {
            departmentList = [];
          });
        }
      } catch (e) {
        print("Error fetching departments: $e");
        setState(() {
          departmentList = [];
        });
      }
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          // Fetch departments when Level and Type are changed or toggle is on
          if (isFilterByLevelAndType && departmentList.isEmpty) {
            fetchDepartments(setState);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF23233A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Text(
              "Add New Circular",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Title"),
                  ),
                  const SizedBox(height: 16),
                  const Text("Category",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCategoryChip("Academic", selectedCategory,
                          (val) => setState(() => selectedCategory = val)),
                      _buildCategoryChip("Administrative", selectedCategory,
                          (val) => setState(() => selectedCategory = val)),
                      _buildCategoryChip("Event", selectedCategory,
                          (val) => setState(() => selectedCategory = val)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Toggle to switch between filtering departments by Level and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filter by Level & Type",
                          style: TextStyle(color: Colors.white70)),
                      Switch(
                        value: isFilterByLevelAndType,
                        onChanged: (val) {
                          setState(() {
                            isFilterByLevelAndType = val;
                            departmentList = [];
                            if (isFilterByLevelAndType) {
                              selectedLevel = "UG";
                              selectedType = "Aided";
                              fetchDepartments(setState);
                            } else {
                              selectedLevel = "";
                              selectedType = "";
                              selectedDepartment = "All";
                              departmentList = ["All"];
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Conditionally show Level and Type dropdowns only if the toggle is ON
                  if (isFilterByLevelAndType) ...[
                    const Text("Level",
                        style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedLevel,
                      items: ["UG", "PG"],
                      onChanged: (val) {
                        setState(() {
                          selectedLevel = val!;
                          departmentList = [];
                          fetchDepartments(setState);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Type", style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedType,
                      items: ["Aided", "Self Financed"],
                      onChanged: (val) {
                        setState(() {
                          selectedType = val!;
                          departmentList = [];
                          fetchDepartments(setState);
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Text("Department",
                      style: TextStyle(color: Colors.white70)),
                  _buildDropdown(
                    value: selectedDepartment,
                    items: departmentList,
                    onChanged: (val) {
                      setState(() {
                        selectedDepartment = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Target Audience",
                      style: TextStyle(color: Colors.white70)),
                  _buildDropdown(
                    value: selectedAudience,
                    items: audiences,
                    onChanged: (val) {
                      setState(() {
                        selectedAudience = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: _inputDecoration("Content"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty &&
                      selectedDepartment.isNotEmpty) {
                    try {
                      final newCircular = {
                        'title': titleController.text,
                        'content': contentController.text,
                        'category': selectedCategory,
                        'level': selectedLevel,
                        'type': selectedType,
                        'department': selectedDepartment,
                        'departmentType': selectedType,
                        'audience': selectedAudience,
                        'createdAt': DateTime.now().toIso8601String(),
                        'staffViewCount': 0,
                        'studentViewCount': 0,
                      };

                      await _circularsRef.push().set(newCircular);
                      Navigator.pop(context);
                      _loadCirculars();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Circular added successfully"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error adding circular: $e"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditCircularDialog(
      BuildContext context, Map<String, dynamic> circular) {
    final titleController = TextEditingController(text: circular['title']);
    final contentController = TextEditingController(text: circular['content']);

    String selectedCategory = circular['category'];
    String selectedAudience = circular['audience'];
    String selectedLevel = circular['level'] ?? "UG";
    String selectedType = circular['type'] ?? "Aided";
    String selectedDepartment = circular['department'] ?? "";

    final audiences = ["All", "Students Only", "Teaching Staff Only"];
    List<String> departmentList = [];

    DatabaseReference departmentsRef =
        FirebaseDatabase.instance.ref().child("departments");
    bool isFilterByLevelAndType = true;
    // Function to fetch departments based on Level and Type
    void fetchDepartments(Function(void Function()) setState) async {
      try {
        final snapshot =
            await departmentsRef.child("$selectedLevel/$selectedType").get();
        if (snapshot.exists) {
          List<dynamic> fetched = snapshot.value as List<dynamic>;
          setState(() {
            departmentList = List<String>.from(fetched);
            if (!departmentList.contains(selectedDepartment)) {
              selectedDepartment = departmentList.isNotEmpty
                  ? departmentList.first
                  : "Select Department";
            }
          });
        } else {
          setState(() {
            departmentList = [];
          });
        }
      } catch (e) {
        print("Error fetching departments: $e");
        setState(() {
          departmentList = [];
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          // Check if the department is "All", then disable Level and Type filtering
          if (selectedDepartment == "All") {
            setState(() {
              isFilterByLevelAndType = false;
              departmentList = ["All"]; // Set department list to "All"
            });
          }

          if (isFilterByLevelAndType && departmentList.isEmpty) {
            fetchDepartments(setState);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF23233A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Text("Edit Circular",
                style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Title"),
                    ),
                    const SizedBox(height: 16),
                    const Text("Category",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildCategoryChip("Academic", selectedCategory,
                            (val) => setState(() => selectedCategory = val)),
                        _buildCategoryChip("Administrative", selectedCategory,
                            (val) => setState(() => selectedCategory = val)),
                        _buildCategoryChip("Event", selectedCategory,
                            (val) => setState(() => selectedCategory = val)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Level",
                        style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedLevel,
                      items: ["UG", "PG"],
                      onChanged: (val) {
                        setState(() {
                          selectedLevel = val!;
                          departmentList = [];
                          fetchDepartments(setState);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Type", style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedType,
                      items: ["Aided", "Self Financed"],
                      onChanged: (val) {
                        setState(() {
                          selectedType = val!;
                          departmentList = [];
                          fetchDepartments(setState);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Department",
                        style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedDepartment,
                      items: departmentList,
                      onChanged: (val) {
                        setState(() {
                          selectedDepartment = val!;
                          // If department is "All", disable level and type filter
                          if (selectedDepartment == "All") {
                            isFilterByLevelAndType = false;
                          } else {
                            isFilterByLevelAndType = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Target Audience",
                        style: TextStyle(color: Colors.white70)),
                    _buildDropdown(
                      value: selectedAudience,
                      items: audiences,
                      onChanged: (val) {
                        setState(() {
                          selectedAudience = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: _inputDecoration("Content"),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty &&
                      selectedDepartment.isNotEmpty) {
                    try {
                      final updatedCircular = {
                        'title': titleController.text,
                        'content': contentController.text,
                        'category': selectedCategory,
                        'level': selectedLevel,
                        'type': selectedType,
                        'department': selectedDepartment,
                        'audience': selectedAudience,
                        'updatedAt': DateTime.now().toIso8601String(),
                        'createdAt': circular['createdAt'],
                        'staffViewCount': circular['staffViewCount'],
                        'studentViewCount': circular['studentViewCount'],
                      };

                      await _circularsRef
                          .child(circular['id'])
                          .update(updatedCircular);

                      Navigator.pop(context);
                      _loadCirculars();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Circular updated successfully"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error updating circular: $e"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Update"),
              ),
            ],
          );
        });
      },
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      );

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          isExpanded: true,
          dropdownColor: const Color(0xFF23233A),
          style: const TextStyle(color: Colors.white),
          underline: Container(),
        ),
      );

  Widget _buildCategoryChip(
    String label,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selected == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.white.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> circular) {
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
            "Are you sure you want to delete the circular '${circular['title']}'?",
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
              onPressed: () async {
                try {
                  // Delete from Firebase
                  await _circularsRef.child(circular['id']).remove();

                  Navigator.of(context).pop();
                  _loadCirculars(); // Refresh the list

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Circular deleted successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error deleting circular: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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

  // Widget _buildCategoryChip(
  //     String label, String selectedCategory, Function(String) onSelected) {
  //   final isSelected = selectedCategory == label;
  //   return ChoiceChip(
  //     label: Text(
  //       label,
  //       style: TextStyle(
  //         color: isSelected ? Colors.white : Colors.white70,
  //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //     selected: isSelected,
  //     selectedColor: label == "Academic"
  //         ? Colors.orange
  //         : label == "Administrative"
  //             ? Colors.green
  //             : Colors.purple,
  //     backgroundColor: Colors.white.withOpacity(0.1),
  //     onSelected: (bool selected) {
  //       if (selected) {
  //         onSelected(label);
  //       }
  //     },
  //   );
  // }
}
