import 'package:cloud_firestore/cloud_firestore.dart';

// one internship / gig posted by a startup
class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category; // e.g. Software Development, Design, Marketing
  final List<String> skillsNeeded;
  final bool isRemote;
  final bool isOpen;
  final DateTime createdAt;

  Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.skillsNeeded,
    required this.isRemote,
    required this.isOpen,
    required this.createdAt,
  });

  factory Opportunity.fromMap(String id, Map<String, dynamic> data) {
    return Opportunity(
      id: id,
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      // skillsNeeded is saved as a list of strings in Firestore
      skillsNeeded: List<String>.from(data['skillsNeeded'] ?? []),
      isRemote: data['isRemote'] ?? false,
      isOpen: data['isOpen'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'category': category,
      'skillsNeeded': skillsNeeded,
      'isRemote': isRemote,
      'isOpen': isOpen,
      'createdAt': createdAt,
    };
  }
}
