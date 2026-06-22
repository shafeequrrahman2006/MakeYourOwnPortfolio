import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muop_web/core/firestore_service.dart';
import 'package:muop_web/providers/contact_form_provider.dart';
import 'package:muop_web/providers/firebase_provider.dart';

class MockFirebaseService extends FirebaseService {
  @override
  bool get isMock => true;

  @override
  Future<void> initialize() async {}
}

class TestFirestoreService extends FirestoreService {
  TestFirestoreService() : super(MockFirebaseService());

  bool saveLeadCalled = false;
  String? lastSavedName;
  String? lastSavedEmail;

  @override
  Future<void> saveLead({
    required String name,
    required String email,
    required String phone,
    required String service,
    required String message,
  }) async {
    saveLeadCalled = true;
    lastSavedName = name;
    lastSavedEmail = email;
  }
}

void main() {
  group('ContactFormNotifier Tests', () {
    late ProviderContainer container;
    late TestFirestoreService testFirestoreService;

    setUp(() {
      testFirestoreService = TestFirestoreService();
      container = ProviderContainer(
        overrides: [
          firestoreServiceProvider.overrideWithValue(testFirestoreService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is idle with no errors', () {
      final state = container.read(contactFormProvider);
      expect(state.status, ContactFormStatus.idle);
      expect(state.nameError, isNull);
      expect(state.emailError, isNull);
      expect(state.phoneError, isNull);
      expect(state.messageError, isNull);
      expect(state.errorMessage, isNull);
    });

    test('Validation fails for empty fields', () {
      final notifier = container.read(contactFormProvider.notifier);
      final isValid = notifier.validate(
        name: '',
        email: '',
        phone: '',
        message: '',
      );

      expect(isValid, isFalse);
      
      final state = container.read(contactFormProvider);
      expect(state.nameError, 'Name is required');
      expect(state.emailError, 'Email is required');
      expect(state.phoneError, 'Phone is required');
      expect(state.messageError, 'Message is required');
    });

    test('Validation fails for invalid email format', () {
      final notifier = container.read(contactFormProvider.notifier);
      final isValid = notifier.validate(
        name: 'John Doe',
        email: 'invalid-email',
        phone: '1234567890',
        message: 'Hello World',
      );

      expect(isValid, isFalse);
      
      final state = container.read(contactFormProvider);
      expect(state.nameError, isNull);
      expect(state.emailError, 'Enter a valid email address');
      expect(state.phoneError, isNull);
      expect(state.messageError, isNull);
    });

    test('Successful submission updates status and calls FirestoreService', () async {
      final notifier = container.read(contactFormProvider.notifier);
      final success = await notifier.submitLead(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        service: 'Portfolio Development',
        message: 'Hello World',
      );

      expect(success, isTrue);
      expect(testFirestoreService.saveLeadCalled, isTrue);
      expect(testFirestoreService.lastSavedName, 'John Doe');
      expect(testFirestoreService.lastSavedEmail, 'john@example.com');

      final state = container.read(contactFormProvider);
      expect(state.status, ContactFormStatus.success);
    });
  });
}
