import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floorbot/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Method to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        // Check if the user already exists in Firestore
        if (!userDoc.exists) {
          // If not, add user data (email and uid) to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'uid': user.uid,
          });
        }

        return UserModel.fromFirebase(user);
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
    return null;
  }


  // Sign up with Google
  Future<UserModel?> signUpWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; 
      }
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(cred);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          return null;
        } else {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'uid': user.uid,
          });
          return UserModel.fromFirebase(user);
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  //Sign out from google
  Future<void> signOutFromGoogle() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Sign In with email and password
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      if (kIsWeb) {
        // Use web-specific method for sign-in
        UserCredential userCredential = await _auth.getRedirectResult();
        return UserModel.fromFirebase(userCredential.user);
      } else {
        // Use mobile-compatible method for sign-in
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return UserModel.fromFirebase(userCredential.user);
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For Web: Google Sign-In uses a redirect method
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final user = userCredential.user;

        if (user != null) {
          return UserModel.fromFirebase(user);
        }
      } else {
        // For Mobile (iOS/Android)
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          return null; // The user canceled the sign-in
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final userDoc = await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            return UserModel.fromFirebase(user);
          } else {
            // Add the user to the Firestore collection if not exists
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'uid': user.uid,
            });
            return UserModel.fromFirebase(user);
          }
        }
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
    return null;
  }

}
