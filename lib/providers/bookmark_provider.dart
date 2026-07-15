import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// keeps track of which opportunities a student saved for later
// we just store a simple list of opportunity ids on the user's doc
class BookmarkProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<String> bookmarkedIds = [];

  void listenToBookmarks(String studentUid) {
    _db.collection('users').doc(studentUid).snapshots().listen((doc) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        bookmarkedIds = List<String>.from(data['bookmarks'] ?? []);
        notifyListeners();
      }
    });
  }

  bool isBookmarked(String opportunityId) {
    return bookmarkedIds.contains(opportunityId);
  }

  // adds or removes the opportunity id from the saved list
  Future<void> toggleBookmark(String studentUid, String opportunityId) async {
    DocumentReference userDoc = _db.collection('users').doc(studentUid);

    if (bookmarkedIds.contains(opportunityId)) {
      await userDoc.update({
        'bookmarks': FieldValue.arrayRemove([opportunityId])
      });
    } else {
      await userDoc.update({
        'bookmarks': FieldValue.arrayUnion([opportunityId])
      });
    }
  }
}
