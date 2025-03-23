import 'dart:collection';

class Staff {
  final String name;
  final String email;
  final String gender;
  final String department;
  final String departmentType;
  final String position;
  final String role;
  final String staffId;
  final int dob;

  Staff({
    required this.name,
    required this.email,
    required this.gender,
    required this.department,
    required this.departmentType,
    required this.position,
    required this.role,
    required this.staffId,
    required this.dob,
  });

  // Convert Firestore document to Staff object
  factory Staff.fromMap(LinkedHashMap<dynamic, dynamic> data) {
    return Staff(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      department: data['department'] ?? '',
      departmentType: data['departmentType'] ?? '',
      position: data['position'] ?? '',
      role: data['role'] ?? '',
      staffId: data['staffId'] ?? '',
      dob: data['dob'] ?? 0,
    );
  }

  // Convert Staff object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'department': department,
      'departmentType': departmentType,
      'position': position,
      'role': role,
      'staffId': staffId,
      'dob': dob,
    };
  }
}

class Student {
  final String name;
  final String email;
  final String gender;
  final String department;
  final String departmentType;
  final String role;
  final String rollNo;
  final int dob;
  final int joinedYear;

  Student({
    required this.name,
    required this.email,
    required this.gender,
    required this.department,
    required this.departmentType,
    required this.role,
    required this.rollNo,
    required this.dob,
    required this.joinedYear,
  });

  // Convert Firestore document to Student object
  factory Student.fromMap(LinkedHashMap<dynamic, dynamic> data) {
    return Student(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      department: data['department'] ?? '',
      departmentType: data['departmentType'] ?? '',
      role: data['role'] ?? '',
      rollNo: data['rollNo'] ?? '',
      dob: data['dob'] ?? 0,
      joinedYear: data['joinedYear'] ?? 0,
    );
  }

  // Convert Student object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'department': department,
      'departmentType': departmentType,
      'role': role,
      'rollNo': rollNo,
      'dob': dob,
      'joinedYear': joinedYear,
    };
  }
}
