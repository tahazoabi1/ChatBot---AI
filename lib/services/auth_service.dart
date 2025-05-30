// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isTeacher = false;
  String _userId = '';
  String _username = '';
  
  // Firebase instance (nullable to handle initialization issues)
  FirebaseAuth? _auth;
  
  // Getters for auth state
  bool get isLoggedIn => _isLoggedIn;
  bool get isTeacher => _isTeacher;
  String get userId => _userId;
  String get username => _username;
  User? get currentUser => _auth?.currentUser;
  
  // Constructor to check if user is already logged in
  AuthService() {
    _initializeFirebase();
  }
  
  // Initialize Firebase safely
  void _initializeFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _checkCurrentUser();
    } catch (e) {
      print('Firebase not initialized, using local auth only: $e');
      _auth = null;
    }
  }
  
  // Check if user is already logged in on app start
  void _checkCurrentUser() {
    if (_auth == null) return;
    
    try {
      final user = _auth!.currentUser;
      if (user != null) {
        _isLoggedIn = true;
        _userId = user.uid;
        _username = user.displayName ?? user.email ?? '';
        notifyListeners();
      }
    } catch (e) {
      print('Error checking current user: $e');
    }
  }
  
  // Hardcoded users for testing
  final Map<String, Map<String, dynamic>> _testUsers = {
    // Teachers
    'NofarA': {'password': 'teacher123', 'isTeacher': true, 'name': 'המורה עדי'},
    'adi': {'password': '123456', 'isTeacher': true, 'name': 'המורה עדי'},
    
    // Students
    'student': {'password': 'student123', 'isTeacher': false, 'name': 'תלמיד בדיקה'},
    'chen': {'password': '123456', 'isTeacher': false, 'name': 'חן לוי'},
    'noa': {'password': '123456', 'isTeacher': false, 'name': 'נועה כהן'},
  };

  // Login with email and password
  Future<void> login(String username, String password, bool isTeacher) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('שם משתמש וסיסמה נדרשים');
      }
      
      // Check against hardcoded test users first
      if (_testUsers.containsKey(username.toLowerCase())) {
        final user = _testUsers[username.toLowerCase()]!;
        if (user['password'] == password && user['isTeacher'] == isTeacher) {
          await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
          
          _isLoggedIn = true;
          _isTeacher = isTeacher;
          _userId = isTeacher ? 'teacher_${username}' : 'student_${username}';
          _username = user['name'];
          notifyListeners();
          return;
        } else {
          throw Exception('שם משתמש או סיסמה שגויים');
        }
      }
      
      // If not a test user, try Firebase Auth (only if available)
      if (_auth != null) {
        try {
          final email = username.contains('@') ? username : '$username@example.com';
          
          final userCredential = await _auth!.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          final user = userCredential.user;
          if (user != null) {
            _isLoggedIn = true;
            _isTeacher = isTeacher;
            _userId = user.uid;
            _username = user.displayName ?? username;
            notifyListeners();
            return;
          } else {
            throw Exception('התחברות נכשלה');
          }
        } catch (e) {
          // If Firebase also fails, show error
          throw Exception('שם משתמש או סיסמה שגויים');
        }
      } else {
        // No Firebase available and not a test user
        throw Exception('שם משתמש או סיסמה שגויים');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Register a new user
  Future<void> register(String username, String email, String password, bool isTeacher) async {
    try {
      // Option 1: Use Firebase Auth (only if available)
      if (_auth != null) {
        try {
          final userCredential = await _auth!.createUserWithEmailAndPassword(
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
      } else {
        // No Firebase available, use mock registration
        await Future.delayed(const Duration(seconds: 1));
        print('User registered (local): $username, $email, isTeacher: $isTeacher');
      }
    } catch (e) {
      throw Exception('שגיאת הרשמה: ${e.toString()}');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      if (_auth != null) {
        await _auth!.signOut();
      }
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
      if (_auth != null) {
        await _auth!.sendPasswordResetEmail(email: email);
      } else {
        throw Exception('שירות האימות אינו זמין');
      }
    } catch (e) {
      throw Exception('שגיאה בשחזור סיסמה: ${e.toString()}');
    }
  }
  
  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth != null) {
        final user = _auth!.currentUser;
        if (user != null) {
          await user.updateDisplayName(displayName);
          await user.updatePhotoURL(photoURL);
          
          _username = user.displayName ?? _username;
          notifyListeners();
        }
      }
    } catch (e) {
      throw Exception('שגיאה בעדכון פרופיל: ${e.toString()}');
    }
  }
}