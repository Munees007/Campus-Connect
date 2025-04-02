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
        loadedCirculars.sort((a, b) => DateTime.parse(b['publishedAt'])
            .compareTo(DateTime.parse(a['publishedAt'])));

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
          Row(
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
                                    builder: (context) =>
                                        CircularDetailPage(circular: circular),
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
                                            "Published: ${_formatDate(circular['publishedAt'])}",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (circular['viewCount'] != null)
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
                                                  "${circular['viewCount']}",
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
    String selectedDepartment = "All Departments";
    String selectedAudience = "All";

    final departments = [
      "All Departments",
      "Computer Science",
      "Electrical Engineering",
      "Mechanical Engineering",
      "Civil Engineering",
      "Electronics & Communication"
    ];

    final audiences = [
      "All",
      "Students Only",
      "Teaching Staff Only",
      "Non-Teaching Staff Only"
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Category",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildCategoryChip("Academic", selectedCategory,
                            (value) {
                          setState(() => selectedCategory = value);
                        }),
                        _buildCategoryChip("Administrative", selectedCategory,
                            (value) {
                          setState(() => selectedCategory = value);
                        }),
                        _buildCategoryChip("Event", selectedCategory, (value) {
                          setState(() => selectedCategory = value);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Department",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDepartment = newValue;
                            });
                          }
                        },
                        items: departments
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF23233A),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Target Audience",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedAudience,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedAudience = newValue;
                            });
                          }
                        },
                        items: audiences
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF23233A),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Content",
                        alignLabelWithHint: true,
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                ),
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
                    // Implement add circular functionality
                    if (titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty) {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        final newCircular = {
                          'title': titleController.text,
                          'content': contentController.text,
                          'category': selectedCategory,
                          'department': selectedDepartment == "All Departments"
                              ? "All"
                              : selectedDepartment,
                          'audience': selectedAudience,
                          'publishedAt': DateTime.now().toIso8601String(),
                          'viewCount': 0,
                        };

                        // Push to Firebase
                        await _circularsRef.push().set(newCircular);

                        Navigator.of(context).pop();
                        _loadCirculars(); // Refresh the list

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("Circular published successfully"),
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
                            content: Text("Error publishing circular: $e"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
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
                  child: const Text("Publish"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCircularDialog(
      BuildContext context, Map<String, dynamic> circular) {
    final titleController = TextEditingController(text: circular['title']);
    final contentController = TextEditingController(text: circular['content']);
    String selectedCategory = circular['category'];
    String selectedDepartment = circular['department'] == "All"
        ? "All Departments"
        : circular['department'];
    String selectedAudience = circular['audience'];

    final departments = [
      "All Departments",
      "Computer Science",
      "Electrical Engineering",
      "Mechanical Engineering",
      "Civil Engineering",
      "Electronics & Communication"
    ];

    final audiences = [
      "All",
      "Students Only",
      "Teaching Staff Only",
      "Non-Teaching Staff Only"
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF23233A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              title: const Text(
                "Edit Circular",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Category",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildCategoryChip("Academic", selectedCategory,
                            (value) {
                          setState(() => selectedCategory = value);
                        }),
                        _buildCategoryChip("Administrative", selectedCategory,
                            (value) {
                          setState(() => selectedCategory = value);
                        }),
                        _buildCategoryChip("Event", selectedCategory, (value) {
                          setState(() => selectedCategory = value);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Department",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDepartment = newValue;
                            });
                          }
                        },
                        items: departments
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF23233A),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Target Audience",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedAudience,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedAudience = newValue;
                            });
                          }
                        },
                        items: audiences
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF23233A),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Content",
                        alignLabelWithHint: true,
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                ),
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
                    if (titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty) {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        final updatedCircular = {
                          'title': titleController.text,
                          'content': contentController.text,
                          'category': selectedCategory,
                          'department': selectedDepartment == "All Departments"
                              ? "All"
                              : selectedDepartment,
                          'audience': selectedAudience,
                          'updatedAt': DateTime.now().toIso8601String(),
                          // Keep original publish date and view count
                          'publishedAt': circular['publishedAt'],
                          'viewCount': circular['viewCount'],
                        };

                        // Update in Firebase
                        await _circularsRef
                            .child(circular['id'])
                            .update(updatedCircular);

                        Navigator.of(context).pop();
                        _loadCirculars(); // Refresh the list

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("Circular updated successfully"),
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
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
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
          },
        );
      },
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

  Widget _buildCategoryChip(
      String label, String selectedCategory, Function(String) onSelected) {
    final isSelected = selectedCategory == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: label == "Academic"
          ? Colors.orange
          : label == "Administrative"
              ? Colors.green
              : Colors.purple,
      backgroundColor: Colors.white.withOpacity(0.1),
      onSelected: (bool selected) {
        if (selected) {
          onSelected(label);
        }
      },
    );
  }
}
