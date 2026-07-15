import 'package:cloud_firestore/cloud_firestore.dart';

// this class holds the basic info we save for every person who signs up
// role is just a simple string, either "student" or "startup"
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // turns a Firestore document into an AppUser object
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      // Firestore stores dates as Timestamp, so we convert it to DateTime
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // turns this object back into a map so we can save it to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
