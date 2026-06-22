import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return FirestoreService(firebaseService);
});

class FirestoreService {
  final FirebaseService _firebaseService;
  final FirebaseFirestore? _firestore;

  FirestoreService(this._firebaseService, {FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  Future<void> saveLead({
    required String name,
    required String email,
    required String phone,
    required String service,
    required String message,
  }) async {
    // 1. Initialize Firebase if it isn't initialized yet
    await _firebaseService.initialize();

    // 2. Respect the isMock flag
    if (_firebaseService.isMock) {
      if (kDebugMode) {
        print('MUOP: [MOCK] Saving lead to portfolio_leads collection:');
        print('      Name: $name, Email: $email, Phone: $phone, Service: $service, Message: $message');
      }
      // Simulate network delay for realistic UI states
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }

    // 3. Perform real Firestore write
    await firestore.collection('portfolio_leads').add({
      'name': name,
      'email': email,
      'phone': phone,
      'service': service,
      'message': message,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}