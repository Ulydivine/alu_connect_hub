import 'package:cloud_firestore/cloud_firestore.dart';

// when a student applies to an opportunity we save one of these
// status can be "pending", "accepted" or "rejected"
class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String studentUid;
  final String studentName;
  final String studentEmail;
  final String coverNote;
  final String status;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.studentUid,
    required this.studentName,
    required this.studentEmail,
    required this.coverNote,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromMap(String id, Map<String, dynamic> data) {
    return Application(
      id: id,
      opportunityId: data['opportunityId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupId: data['startupId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      coverNote: data['coverNote'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'coverNote': coverNote,
      'status': status,
      'appliedAt': appliedAt,
    };
  }
}
