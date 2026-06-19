import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../core/firebase_config.dart';
import '../models/portfolio_request.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class FirebaseService {
  bool _isInitialized = false;
  bool _isMock = true;
  
  // Real Firebase instances
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseAnalytics? _analytics;

  // Mock State
  final List<PortfolioRequest> _mockRequests = [];
  final StreamController<List<PortfolioRequest>> _mockStreamController = 
      StreamController<List<PortfolioRequest>>.broadcast();

  bool get isMock => _isMock;
  bool get isInitialized => _isInitialized;

  bool _isLocalAdminLoggedIn = false;
  bool get isLocalAdminLoggedIn => _isLocalAdminLoggedIn;

  FirebaseService() {
    // Populate mock data initially so the dashboard has contents on first run
    _populateMockData();
  }

  void _populateMockData() {
    _emitMockRequests();
  }

  void _emitMockRequests() {
    // Sort mock requests by date descending
    _mockRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!_mockStreamController.isClosed) {
      _mockStreamController.add(List.from(_mockRequests));
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (MUOPFirebaseConfig.isPlaceholder) {
      if (kDebugMode) {
        print('MUOP: Firebase configured with placeholders. Operating in MOCK mode.');
      }
      _isMock = true;
      _isInitialized = true;
      return;
    }

    try {
      await Firebase.initializeApp(
        options: MUOPFirebaseConfig.currentPlatform,
      );
      
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      
      try {
        _analytics = FirebaseAnalytics.instance;
      } catch (e) {
        if (kDebugMode) print('Analytics not supported on this platform: $e');
      }

      _isMock = false;
      _isInitialized = true;
      if (kDebugMode) print('MUOP: Real Firebase initialized successfully.');
    } catch (e) {
      if (kDebugMode) {
        print('MUOP: Failed to initialize Firebase ($e). Falling back to MOCK mode.');
      }
      _isMock = true;
      _isInitialized = true;
    }
  }

  User? get currentUser => _auth?.currentUser;

  Future<void> signInAnonymously() async {
    await initialize();
    if (_isMock) {
      if (kDebugMode) print('MUOP: Anonymous sign in (MOCK) successful.');
      return;
    }
    
    try {
      if (_auth!.currentUser != null) {
        if (kDebugMode) print('MUOP: Already signed in: ${_auth!.currentUser!.email ?? "Anonymous"}');
        return;
      }
      final userCredential = await _auth!.signInAnonymously().timeout(const Duration(seconds: 5));
      if (kDebugMode) {
        print('MUOP: Anonymous sign in successful. UID: ${userCredential.user?.uid}');
      }
    } catch (e) {
      if (kDebugMode) print('MUOP: Anonymous sign in failed: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await initialize();
    if (_isMock) {
      if (email == 'shafeequrr309@gmail.com' && password == 'Ss@987654') {
        if (kDebugMode) print('MUOP: Admin login (MOCK) successful.');
        return;
      } else {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Invalid email or password for Admin.',
        );
      }
    }
    
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      _isLocalAdminLoggedIn = false;
    } on FirebaseAuthException catch (e) {
      // Auto-register the admin user on the fly if it doesn't exist yet on the live Firebase
      if ((e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') &&
          email == 'shafeequrr309@gmail.com' && password == 'Ss@987654') {
        try {
          await _auth!.createUserWithEmailAndPassword(email: email, password: password);
          _isLocalAdminLoggedIn = false;
          if (kDebugMode) print('MUOP: Admin user created and signed in successfully.');
        } catch (signUpError) {
          if (kDebugMode) print('MUOP: Failed to create admin user: $signUpError');
          // If we fail to create the user, fallback to local admin session using anonymous auth!
          _isLocalAdminLoggedIn = true;
          if (kDebugMode) print('MUOP: Fallback to local admin login using anonymous credentials.');
        }
      } else if (email == 'shafeequrr309@gmail.com' && password == 'Ss@987654') {
        // Any other error (like 400 Bad Request/operation-not-allowed) for the correct admin credentials
        _isLocalAdminLoggedIn = true;
        if (kDebugMode) print('MUOP: Fallback to local admin login due to Firebase error: $e');
      } else {
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    _isLocalAdminLoggedIn = false;
    if (_isMock) return;
    await _auth?.signOut();
  }

  Future<String> generateNextRequestId() async {
    if (_isMock) {
      int maxNum = 0;
      for (final req in _mockRequests) {
        final parts = req.requestId.split('-');
        if (parts.length == 3) {
          final numStr = parts[2];
          final num = int.tryParse(numStr) ?? 0;
          if (num > maxNum) maxNum = num;
        }
      }
      final nextNum = maxNum + 1;
      final padded = nextNum.toString().padLeft(3, '0');
      return 'MUOP-2026-$padded';
    }

    try {
      final snapshot = await _firestore!
          .collection('portfolio_requests')
          .orderBy('requestId', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        return 'MUOP-2026-001';
      }

      final lastId = snapshot.docs.first.data()['requestId'] as String? ?? 'MUOP-2026-000';
      final parts = lastId.split('-');
      if (parts.length == 3) {
        final numStr = parts[2];
        final num = int.tryParse(numStr) ?? 0;
        final nextNum = num + 1;
        final padded = nextNum.toString().padLeft(3, '0');
        return 'MUOP-2026-$padded';
      }
      return 'MUOP-2026-001';
    } catch (e) {
      if (kDebugMode) print('MUOP: Error generating Request ID: $e. Using timestamp code.');
      // Fallback unique code
      final stamp = DateTime.now().millisecondsSinceEpoch.toString();
      final shortened = stamp.substring(stamp.length - 3);
      return 'MUOP-2026-$shortened';
    }
  }

  Future<String> uploadResume(String requestId, Uint8List bytes, String fileName) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network latency
      return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    }

    try {
      final extension = fileName.split('.').last;
      final ref = _storage!.ref().child('resumes/$requestId/resume.$extension');
      
      // Upload task
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'application/pdf'), // Adjust content type if docx/doc
      );
      
      final snapshot = await uploadTask.timeout(const Duration(seconds: 10));
      final url = await snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 5));
      return url;
    } catch (e) {
      if (kDebugMode) print('MUOP: Resume upload failed: $e');
      throw Exception('Resume upload failed: $e');
    }
  }

  Future<PortfolioRequest> submitRequest({
    required String fullName,
    required String whatsapp,
    required String email,
    required String status,
    required String desiredRole,
    required String selectedPackage,
    required Uint8List? resumeBytes,
    required String? resumeFileName,
  }) async {
    await initialize();
    
    // Generate Request ID
    final requestId = await generateNextRequestId();
    
    String resumeUrl = '';
    if (resumeBytes != null && resumeFileName != null) {
      try {
        resumeUrl = await uploadResume(requestId, resumeBytes, resumeFileName);
      } catch (e) {
        if (kDebugMode) {
          print('MUOP: Resume upload failed but continuing request submission: $e');
        }
      }
    }

    final newRequest = PortfolioRequest(
      requestId: requestId,
      fullName: fullName,
      whatsapp: whatsapp,
      email: email,
      status: status,
      desiredRole: desiredRole,
      selectedPackage: selectedPackage,
      resumeUrl: resumeUrl,
      requestStatus: 'Pending',
      createdAt: DateTime.now(),
    );

    if (_isMock) {
      _mockRequests.add(newRequest);
      _emitMockRequests();
      // Track event
      if (kDebugMode) print('MUOP: Saved mock request $requestId.');
      return newRequest;
    }

    try {
      await _firestore!
          .collection('portfolio_requests')
          .doc(requestId)
          .set(newRequest.toMap())
          .timeout(const Duration(seconds: 5));

      // Log to analytics if initialized
      try {
        await _analytics?.logEvent(
          name: 'portfolio_request_submitted',
          parameters: {
            'package': selectedPackage,
            'status': status,
            'role': desiredRole,
          },
        );
      } catch (_) {}

      return newRequest;
    } catch (e) {
      if (kDebugMode) print('MUOP: Failed to save request in Firestore: $e');
      // Save locally as fallback
      _mockRequests.add(newRequest);
      _emitMockRequests();
      return newRequest;
    }
  }

  Stream<List<PortfolioRequest>> streamRequests() async* {
    await initialize();
    if (_isMock) {
      yield List.from(_mockRequests);
      yield* _mockStreamController.stream;
    } else {
      yield* _firestore!
          .collection('portfolio_requests')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => PortfolioRequest.fromMap(doc.data())).toList();
      });
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await initialize();
    if (_isMock) {
      final idx = _mockRequests.indexWhere((r) => r.requestId == requestId);
      if (idx != -1) {
        _mockRequests[idx] = _mockRequests[idx].copyWith(requestStatus: status);
        _emitMockRequests();
      }
      return;
    }

    try {
      await _firestore!
          .collection('portfolio_requests')
          .doc(requestId)
          .update({'requestStatus': status});
    } catch (e) {
      if (kDebugMode) print('MUOP: Failed to update status: $e');
      // Fallback local update
      final idx = _mockRequests.indexWhere((r) => r.requestId == requestId);
      if (idx != -1) {
        _mockRequests[idx] = _mockRequests[idx].copyWith(requestStatus: status);
        _emitMockRequests();
      }
    }
  }

  Future<void> deleteRequest(String requestId) async {
    await initialize();
    if (_isMock) {
      _mockRequests.removeWhere((r) => r.requestId == requestId);
      _emitMockRequests();
      return;
    }

    try {
      await _firestore!
          .collection('portfolio_requests')
          .doc(requestId)
          .delete();
      
      // Delete corresponding resume file in storage if possible (optional cleanup)
      try {
        final ref = _storage!.ref().child('resumes/$requestId/resume.pdf');
        await ref.delete();
      } catch (_) {}
    } catch (e) {
      if (kDebugMode) print('MUOP: Failed to delete request: $e');
      // Fallback local delete
      _mockRequests.removeWhere((r) => r.requestId == requestId);
      _emitMockRequests();
    }
  }
}
