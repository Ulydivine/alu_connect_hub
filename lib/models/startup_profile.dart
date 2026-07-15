import 'package:cloud_firestore/cloud_firestore.dart';

// this is the profile a startup fills in after they sign up
// isVerified starts as false, only an admin can flip it to true
// students should only see opportunities from startups that are verified
class StartupProfile {
  final String startupId; // same value as the owner's uid
  final String ownerUid;
  final String startupName;
  final String description;
  final String category;
  final String contactEmail;
  final bool isVerified;
  final DateTime createdAt;

  StartupProfile({
    required this.startupId,
    required this.ownerUid,
    required this.startupName,
    required this.description,
    required this.category,
    required this.contactEmail,
    required this.isVerified,
    required this.createdAt,
  });

  factory StartupProfile.fromMap(String id, Map<String, dynamic> data) {
    return StartupProfile(
      startupId: id,
      ownerUid: data['ownerUid'] ?? '',
      startupName: data['startupName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'startupName': startupName,
      'description': description,
      'category': category,
      'contactEmail': contactEmail,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }
}
