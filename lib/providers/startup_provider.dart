import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/startup_profile.dart';

// handles creating a startup profile and the admin verification step
class StartupProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StartupProfile? myStartup;
  List<StartupProfile> pendingStartups = [];

  // creates the startup profile doc, id is the same as the owner's uid
  // isVerified is always false when first created, admin has to approve it
  Future<void> createStartupProfile(StartupProfile profile) async {
    await _db.collection('startups').doc(profile.ownerUid).set(profile.toMap());
    myStartup = profile;
    notifyListeners();
  }

  Future<void> loadMyStartup(String ownerUid) async {
    DocumentSnapshot doc = await _db.collection('startups').doc(ownerUid).get();
    if (doc.exists) {
      myStartup = StartupProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // admin screen uses this to see every startup that still needs approval
  void listenToPendingStartups() {
    _db
        .collection('startups')
        .where('isVerified', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      pendingStartups = snapshot.docs
          .map((doc) => StartupProfile.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<void> approveStartup(String startupId) async {
    await _db.collection('startups').doc(startupId).update({'isVerified': true});
  }

  Future<void> rejectStartup(String startupId) async {
    await _db.collection('startups').doc(startupId).delete();
  }
}
