import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('Starting signup for: $email');
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return {'success': false, 'error': 'Failed to create user account'};
      }

      print('User created: ${userCredential.user!.uid}');

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      // Send email verification with action code settings
      try {
        await userCredential.user!.sendEmailVerification();
        print('Verification email sent to: $email');
      } catch (e) {
        print('Error sending verification email: $e');
        // Don't fail the signup if email sending fails
      }

      // Create user document in Firestore
      final userData = {
        'email': email,
        'displayName': displayName,
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationReminders': true,
        'emailUpdates': false,
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      print('User document created in Firestore');

      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Account created! Please check your email to verify.'
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during sign up.';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('Signup error: $e');
      return {'success': false, 'error': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting signin for: $email');
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return {'success': false, 'error': 'Failed to sign in'};
      }

      // Reload user to get latest email verification status
      await userCredential.user!.reload();
      User? user = _auth.currentUser;

      print('User signed in. Email verified: ${user?.emailVerified}');

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'error': 'Please verify your email before signing in. Check your inbox and spam folder.'
        };
      }

      // Update email verified status in Firestore
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': true,
            'lastLogin': FieldValue.serverTimestamp(),
          });
          print('User document updated in Firestore');
        } catch (e) {
          print('Error updating user document: $e');
          // Continue even if Firestore update fails
        }
      }

      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during sign in.';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('Signin error: $e');
      return {'success': false, 'error': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Resend Verification Email
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user logged in'};
      }
      
      // Reload user to get latest verification status
      await user.reload();
      user = _auth.currentUser;
      
      if (user != null && user.emailVerified) {
        return {'success': false, 'error': 'Email is already verified'};
      }
      
      if (user != null) {
        await user.sendEmailVerification();
        print('Verification email resent to: ${user.email}');
        return {
          'success': true,
          'message': 'Verification email sent! Please check your inbox and spam folder.'
        };
      }
      
      return {'success': false, 'error': 'User not found'};
    } on FirebaseAuthException catch (e) {
      print('Resend verification error: ${e.code} - ${e.message}');
      if (e.code == 'too-many-requests') {
        return {
          'success': false,
          'error': 'Too many requests. Please wait a few minutes before trying again.'
        };
      }
      return {
        'success': false,
        'error': e.message ?? 'Failed to send verification email'
      };
    } catch (e) {
      print('Resend verification error: $e');
      return {
        'success': false,
        'error': 'Failed to send verification email: ${e.toString()}'
      };
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user settings
  Future<bool> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(uid).update(settings);
      return true;
    } catch (e) {
      print('Error updating user settings: $e');
      return false;
    }
  }
}