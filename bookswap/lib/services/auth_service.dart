// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // TODO: Implement signup
      // UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      //
      // await userCredential.user?.updateDisplayName(displayName);
      // await userCredential.user?.sendEmailVerification();
      //
      // await _firestore.collection('users').doc(userCredential.user!.uid).set({
      //   'email': email,
      //   'displayName': displayName,
      //   'emailVerified': false,
      //   'createdAt': DateTime.now().toIso8601String(),
      //   'notificationReminders': true,
      //   'emailUpdates': false,
      // });
      //
      // return {'success': true, 'user': userCredential.user};
      
      return {'success': true, 'message': 'User created successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Implement signin
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      //
      // if (!userCredential.user!.emailVerified) {
      //   return {
      //     'success': false,
      //     'error': 'Please verify your email before signing in'
      //   };
      // }
      //
      // return {'success': true, 'user': userCredential.user};
      
      return {'success': true, 'message': 'Signed in successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Sign Out
  Future<void> signOut() async {
    // await _auth.signOut();
  }

  // Get Current User
  // User? getCurrentUser() {
  //   return _auth.currentUser;
  // }

  // Resend Verification Email
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      // User? user = _auth.currentUser;
      // if (user != null && !user.emailVerified) {
      //   await user.sendEmailVerification();
      //   return {'success': true, 'message': 'Verification email sent'};
      // }
      return {'success': false, 'error': 'User not found or already verified'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}