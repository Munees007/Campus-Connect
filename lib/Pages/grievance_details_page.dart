import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class GrievanceDetailPage extends StatefulWidget {
  final String grievanceId;
  final Map<dynamic, dynamic> grievanceData;

  const GrievanceDetailPage({
    super.key,
    required this.grievanceId,
    required this.grievanceData,
  });

  @override
  State<GrievanceDetailPage> createState() => _GrievanceDetailPageState();
}

class _GrievanceDetailPageState extends State<GrievanceDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  late String userId;
  late String userName;
  late bool isStaff;

  @override
  void initState() {
    super.initState();
    var userData = Hive.box('userBox').get('userData');
    userName = userData['name'];
    isStaff = userData['role'] == "staff";
    userId = isStaff ? userData['staffId'] : userData['rollNo'];
  }

  void _sendReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reply cannot be empty!")));
      return;
    }

    DatabaseReference replyRef = FirebaseDatabase.instance
        .ref("grievances/${widget.grievanceId}/replies")
        .push();

    await replyRef.set({
      'userId': userId,
      'userName': userName,
      'message': _replyController.text.trim(),
      'isStaff': isStaff,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _replyController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic>? replies = widget.grievanceData['replies'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grievance Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGrievanceDetails(),
              const SizedBox(height: 10),
              _buildRepliesSection(replies),
              _buildReplyInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrievanceDetails() {
    return Container(
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
            "📌 ${widget.grievanceData['title']}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.grievanceData['details'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(Map<dynamic, dynamic>? replies) {
    return Expanded(
      child: replies != null && replies.isNotEmpty
          ? ListView(
              children: replies.entries
                  .map((reply) => _buildReplyCard(reply))
                  .toList(),
            )
          : const Center(
              child: Text(
                "No replies yet.",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
    );
  }

  Widget _buildReplyCard(MapEntry<dynamic, dynamic> reply) {
    bool isStaffReply = reply.value['isStaff'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isStaffReply
            ? Colors.blueAccent.withOpacity(0.2)
            : Colors.greenAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isStaffReply
              ? Colors.blueAccent.withOpacity(0.3)
              : Colors.greenAccent.withOpacity(0.3),
        ),
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
            isStaffReply
                ? "👨‍🏫 ${reply.value['userName']} (Staff)"
                : "🎓 ${reply.value['userName']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reply.value['message'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      reply.value['timestamp'])),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
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
        children: [
          TextField(
            controller: _replyController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your reply...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Send Reply",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
