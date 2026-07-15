import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/application.dart';

// handles a student applying to an opportunity, and a startup managing
// the applications it receives
class ApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Application> myApplications = [];
  List<Application> applicantsForOpportunity = [];

  // student submits an application to an opportunity
  Future<String?> submitApplication(Application application) async {
    // stop a student from applying twice to the same opportunity
    QuerySnapshot existing = await _db
        .collection('applications')
        .where('opportunityId', isEqualTo: application.opportunityId)
        .where('studentUid', isEqualTo: application.studentUid)
        .get();

    if (existing.docs.isNotEmpty) {
      return "You already applied to this opportunity";
    }

    await _db.collection('applications').add(application.toMap());
    return null; // null means success, no error
  }

  // real time list of everything the logged in student has applied to
  void listenToMyApplications(String studentUid) {
    _db
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      myApplications = snapshot.docs
          .map((doc) => Application.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  // real time list of students who applied to one specific opportunity
  void listenToApplicants(String opportunityId) {
    _db
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      applicantsForOpportunity = snapshot.docs
          .map((doc) => Application.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  // startup accepts or rejects a student's application
  Future<void> updateApplicationStatus(
      String applicationId, String newStatus) async {
    await _db
        .collection('applications')
        .doc(applicationId)
        .update({'status': newStatus});
  }
}
