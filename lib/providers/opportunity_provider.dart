import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/opportunity.dart';

// this provider keeps the list of opportunities up to date
// it listens to Firestore in real time so new posts show up right away
class OpportunityProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Opportunity> allOpportunities = [];
  bool isLoading = true;

  // the current search text and category filter typed by the student
  String searchText = "";
  String categoryFilter = "All";

  OpportunityProvider() {
    _listenToOpportunities();
  }

  void _listenToOpportunities() {
    _db
        .collection('opportunities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      allOpportunities = snapshot.docs
          .map((doc) => Opportunity.fromMap(doc.id, doc.data()))
          .toList();
      isLoading = false;
      notifyListeners();
    });
  }

  // returns opportunities filtered by search text + category + open only
  List<Opportunity> get filteredOpportunities {
    List<Opportunity> result = [];

    for (var op in allOpportunities) {
      if (!op.isOpen) continue;

      bool matchesCategory =
          categoryFilter == "All" || op.category == categoryFilter;

      bool matchesSearch = searchText.isEmpty ||
          op.title.toLowerCase().contains(searchText.toLowerCase()) ||
          op.description.toLowerCase().contains(searchText.toLowerCase());

      if (matchesCategory && matchesSearch) {
        result.add(op);
      }
    }

    return result;
  }

  void updateSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  void updateCategoryFilter(String category) {
    categoryFilter = category;
    notifyListeners();
  }

  // used by a startup to see only their own posted opportunities
  List<Opportunity> myOpportunities(String startupId) {
    return allOpportunities.where((op) => op.startupId == startupId).toList();
  }

  Future<void> postOpportunity(Opportunity newOpportunity) async {
    await _db.collection('opportunities').add(newOpportunity.toMap());
  }

  Future<void> closeOpportunity(String opportunityId) async {
    await _db
        .collection('opportunities')
        .doc(opportunityId)
        .update({'isOpen': false});
  }
}
