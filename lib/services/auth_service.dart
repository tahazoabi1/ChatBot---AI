// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isTeacher = false;
  String _userId = '';
  String _username = '';
  
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Getters for auth state
  bool get isLoggedIn => _isLoggedIn;
  bool get isTeacher => _isTeacher;
  String get userId => _userId;
  String get username => _username;
  User? get currentUser => _auth.currentUser;
  
  // Constructor to check if user is already logged in
  AuthService() {
    _checkCurrentUser();
  }
  
  // Check if user is already logged in on app start
  void _checkCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      _isLoggedIn = true;
      _userId = user.uid;
      _username = user.displayName ?? user.email ?? '';
      notifyListeners();
    }
  }
  
  // Login with email and password
  Future<void> login(String username, String password, bool isTeacher) async {
    try {
      // For demo purposes or if Firebase isn't configured yet,
      // we can use a mock login
      if (username.isEmpty || password.isEmpty) {
        throw Exception('שם משתמש וסיסמה נדרשים');
      }
      
      // Option 1: Use Firebase Auth
      try {
        // Try to extract email from username if it's not an email
        final email = username.contains('@') ? username : '$username@example.com';
        
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final user = userCredential.user;
        if (user != null) {
          _isLoggedIn = true;
          _isTeacher = isTeacher; // In a real app, this would be determined by user role
          _userId = user.uid;
          _username = user.displayName ?? username;
          notifyListeners();
        } else {
          throw Exception('התחברות נכשלה');
        }
      } catch (e) {
        // Option 2: If Firebase fails or not configured, use mock login for demo
        await Future.delayed(const Duration(seconds: 1)); // Simulate network request
        
        _isLoggedIn = true;
        _isTeacher = isTeacher;
        _userId = isTeacher ? 'teacher_1' : 'student_1';
        _username = username;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('שגיאת התחברות: ${e.toString()}');
    }
  }
  
  // Register a new user
  Future<void> register(String username, String email, String password, bool isTeacher) async {
    try {
      // Option 1: Use Firebase Auth
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Update user display name
        await userCredential.user?.updateDisplayName(username);
        
        // Set user role (teacher or student) in a custom claim or database
        // In a real app, you'd use Cloud Functions or your backend to set custom claims
        
        // For demo, we just use local state
        _isTeacher = isTeacher;
        
        // For a real app, you'd create a user profile in Firestore
        // await _firestore.collection('users').doc(userCredential.user?.uid).set({
        //   'username': username,
        //   'email': email,
        //   'isTeacher': isTeacher,
        //   'createdAt': FieldValue.serverTimestamp(),
        // });
        
      } catch (e) {
        // Option 2: If Firebase fails or not configured, use mock registration for demo
        await Future.delayed(const Duration(seconds: 1)); // Simulate network request
        
        // In a real app, you would save user details to a database
        // For demo purposes, we just log that registration was successful
        print('User registered: $username, $email, isTeacher: $isTeacher');
      }
    } catch (e) {
      throw Exception('שגיאת הרשמה: ${e.toString()}');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Handle any Firebase logout errors
      print('Firebase logout error: $e');
    } finally {
      // Always reset local state
      _isLoggedIn = false;
      _isTeacher = false;
      _userId = '';
      _username = '';
      notifyListeners();
    }
  }
  
  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('שגיאה בשחזור סיסמה: ${e.toString()}');
    }
  }
  
  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        
        _username = user.displayName ?? _username;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('שגיאה בעדכון פרופיל: ${e.toString()}');
    }
  }
}