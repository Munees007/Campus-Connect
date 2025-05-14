import 'package:campus_connect/Pages/admin/circular_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CircularDisplayWidget extends StatefulWidget {
  final String role; // 'student' or 'staff'
  final String department, level, type, userId, filterRole;

  const CircularDisplayWidget(
      {super.key,
      required this.userId,
      required this.role,
      required this.filterRole,
      required this.department,
      required this.level,
      required this.type});

  @override
  State<CircularDisplayWidget> createState() => _CircularDisplayWidgetState();
}

class _CircularDisplayWidgetState extends State<CircularDisplayWidget> {
  final DatabaseReference _circularsRef =
      FirebaseDatabase.instance.ref().child('circulars');
  List<Map<String, dynamic>> filteredCirculars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
  }

  Future<void> _fetchCirculars() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _circularsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> allCirculars = [];

        data.forEach((key, value) {
          final circular = Map<String, dynamic>.from(value as Map);
          circular['id'] = key;
          allCirculars.add(circular);
        });

        List<Map<String, dynamic>> filtered = allCirculars.where((circular) {
          final departmentMatch = (circular['department'] == 'All') ||
              (circular['department'] == widget.department &&
                  circular["level"] == widget.level &&
                  circular["type"] == widget.type);

          final audienceMatch = (circular['audience'] == 'All') ||
              (circular['audience'].toLowerCase() ==
                  widget.filterRole.toLowerCase());

          return departmentMatch && audienceMatch;
        }).toList();

        filtered.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          filteredCirculars = filtered;
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
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent))
        : filteredCirculars.isEmpty
            ? Center(
                child: Text(
                  "No circulars found",
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchCirculars,
                color: Colors.blueAccent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCirculars.length,
                  itemBuilder: (context, index) {
                    final circular = filteredCirculars[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CircularDetailPage(
                              circular: circular,
                              role: widget.role,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                circular['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildBadge(
                                    circular['category'],
                                    _getCategoryColor(circular['category']),
                                  ),
                                  _buildBadge(
                                    circular['department'] ?? 'All Departments',
                                    Colors.blue,
                                  ),
                                  _buildBadge(
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
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (circular['viewCount'] != null)
                                    Row(
                                      children: [
                                        Icon(Icons.visibility,
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${circular['viewCount']}",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
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
              );
  }

  Widget _buildBadge(String text, Color color) {
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
}
