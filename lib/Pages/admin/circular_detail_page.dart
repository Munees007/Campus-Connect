import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class CircularDetailPage extends StatefulWidget {
  final Map<String, dynamic> circular;

  const CircularDetailPage({super.key, required this.circular});

  @override
  State<CircularDetailPage> createState() => _CircularDetailPageState();
}

class _CircularDetailPageState extends State<CircularDetailPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      final DatabaseReference circularRef = FirebaseDatabase.instance
          .ref()
          .child('circulars')
          .child(widget.circular['id']);

      // Get current view count
      final snapshot = await circularRef.child('viewCount').get();
      int currentCount = 0;

      if (snapshot.exists) {
        currentCount = snapshot.value as int;
      }

      // Increment view count
      await circularRef.update({'viewCount': currentCount + 1});
    } catch (e) {
      // Handle error silently
      debugPrint("Error incrementing view count: $e");
    }
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
    return DateFormat('dd MMMM yyyy, hh:mm a').format(date);
  }

  Widget _buildInfoItem(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circular = widget.circular;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Circular Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          circular['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(circular['category'])
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          circular['category'],
                          style: TextStyle(
                            color: _getCategoryColor(circular['category']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Publication info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoItem(
                          "Published On",
                          _formatDate(circular['publishedAt']),
                          icon: Icons.calendar_today,
                        ),
                        _buildInfoItem(
                          "Department",
                          circular['department'] ?? 'All Departments',
                          icon: Icons.business,
                        ),
                        _buildInfoItem(
                          "Target Audience",
                          circular['audience'] ?? 'All',
                          icon: Icons.people,
                        ),
                        if (circular['viewCount'] != null)
                          _buildInfoItem(
                            "Views",
                            circular['viewCount'].toString(),
                            icon: Icons.visibility,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  const Text(
                    "Content",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      circular['content'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Admin actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // You'll need to pass the edit function to this page or implement it here
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Circular"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show delete confirmation
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF23233A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          title: const Text(
                            "Confirm Deletion",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            "Are you sure you want to delete this circular?",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
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
                                  setState(() {
                                    isLoading = true;
                                  });

                                  // Delete from Firebase
                                  await FirebaseDatabase.instance
                                      .ref()
                                      .child('circulars')
                                      .child(circular['id'])
                                      .remove();

                                  // Pop twice to go back to the list
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.of(context)
                                      .pop(); // Go back to list

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Circular deleted successfully"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.of(context).pop(); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Error deleting circular: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
