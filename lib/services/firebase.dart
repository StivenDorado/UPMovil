// lib/services/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static const FirebaseOptions _options = FirebaseOptions(
    apiKey: "AIzaSyDmtKoBOCsoYUTG12LZr069ZhIRVbClc94",
    authDomain: "arrendamientos-80c2a.firebaseapp.com",
    projectId: "arrendamientos-80c2a",
    storageBucket: "arrendamientos-80c2a.appspot.com", // ← CORREGIDO
    messagingSenderId: "32381451979",
    appId: "1:32381451979:web:923a8e40929f827758e54e",
    measurementId: "G-KH906XKVKZ",
  );

  static Future<void> initialize() async {
    await Firebase.initializeApp(options: _options);
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
}
