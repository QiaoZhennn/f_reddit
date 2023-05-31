import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
      clientId:
          '624268864963-v4poi36tcpfc28vvtp2n38f4atat1c2q.apps.googleusercontent.com');
});
