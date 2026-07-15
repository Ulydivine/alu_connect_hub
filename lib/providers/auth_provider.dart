import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../constants.dart';

// this provider keeps track of who is logged in and their role
// every screen that needs to know "who is the current user" can use this
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? myUser;
  bool isLoading = false;
  String errorMessage = "";

  // stays false until we know for sure if someone is logged in or not
  // this stops the app from flashing the login screen for a split second
  bool authChecked = false;

  AuthProvider() {
    // whenever login state changes (login, logout, app restart) this runs
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        myUser = null;
        authChecked = true;
        notifyListeners();
      } else {
        await _loadUserData(firebaseUser.uid);
        authChecked = true;
        notifyListeners();
      }
    });
  }

  bool get isLoggedIn => myUser != null;

  bool get isAdmin => myUser != null && myUser!.email == adminEmail;

  // grabs the user's profile info from the "users" collection in Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        myUser = AppUser.fromMap(uid, doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Could not load user data";
      notifyListeners();
    }
  }

  // creates a new account and saves basic profile info
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = result.user!.uid;

      AppUser newUser = AppUser(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      // save the profile info in Firestore under users/uid
      await _db.collection('users').doc(uid).set(newUser.toMap());

      myUser = newUser;
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message ?? "Sign up failed";
      notifyListeners();
      return false;
    }
  }

  // logs a user in with email and password
  Future<bool> logIn(String email, String password) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadUserData(result.user!.uid);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message ?? "Login failed";
      notifyListeners();
      return false;
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
    myUser = null;
    notifyListeners();
  }
}
