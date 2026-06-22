import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firestore_service.dart';

/// Represents the status of the contact form submission.
enum ContactFormStatus { idle, loading, success, error }

/// Holds the UI state of the contact form, including validation errors.
class ContactFormState {
  final ContactFormStatus status;
  final String? nameError;
  final String? emailError;
  final String? phoneError;
  final String? messageError;
  final String? errorMessage;

  ContactFormState({
    this.status = ContactFormStatus.idle,
    this.nameError,
    this.emailError,
    this.phoneError,
    this.messageError,
    this.errorMessage,
  });

  ContactFormState copyWith({
    ContactFormStatus? status,
    String? nameError,
    String? emailError,
    String? phoneError,
    String? messageError,
    String? errorMessage,
  }) {
    return ContactFormState(
      status: status ?? this.status,
      nameError: nameError, // Passed as null will clear the error
      emailError: emailError,
      phoneError: phoneError,
      messageError: messageError,
      errorMessage: errorMessage,
    );
  }
}

/// A StateNotifier that controls validation, loading state, and Firestore writes.
class ContactFormNotifier extends StateNotifier<ContactFormState> {
  final FirestoreService _firestoreService;

  ContactFormNotifier(this._firestoreService) : super(ContactFormState());

  /// Performs client-side form validation.
  bool validate({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) {
    bool isValid = true;
    String? nameErr;
    String? emailErr;
    String? phoneErr;
    String? messageErr;

    // Validate Name: is required
    if (name.trim().isEmpty) {
      nameErr = 'Name is required';
      isValid = false;
    }

    // Validate Email: is required and valid
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.trim().isEmpty) {
      emailErr = 'Email is required';
      isValid = false;
    } else if (!emailPattern.hasMatch(email.trim())) {
      emailErr = 'Enter a valid email address';
      isValid = false;
    }

    // Validate Phone: is required
    if (phone.trim().isEmpty) {
      phoneErr = 'Phone is required';
      isValid = false;
    }

    // Validate Message: is required
    if (message.trim().isEmpty) {
      messageErr = 'Message is required';
      isValid = false;
    }

    state = state.copyWith(
      nameError: nameErr,
      emailError: emailErr,
      phoneError: phoneErr,
      messageError: messageErr,
    );

    return isValid;
  }

  /// Handles form submission: validates, updates state to loading,
  /// triggers the Firestore write, and marks success or error.
  Future<bool> submitLead({
    required String name,
    required String email,
    required String phone,
    required String service,
    required String message,
  }) async {
    // 1. Form Validation check
    if (!validate(name: name, email: email, phone: phone, message: message)) {
      return false;
    }

    // 2. Set loading state to disable UI elements
    state = state.copyWith(status: ContactFormStatus.loading);

    try {
      // 3. Firestore write operation using FirestoreService
      await _firestoreService.saveLead(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        service: service.trim(),
        message: message.trim(),
      );

      // 4. Update state on success
      state = state.copyWith(status: ContactFormStatus.success);
      return true;
    } catch (e) {
      // 5. Update state on failure and log the error
      if (kDebugMode) {
        print('Firebase exception inside contact form: $e');
      }
      state = state.copyWith(
        status: ContactFormStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resets the form status and validation state.
  void reset() {
    state = ContactFormState();
  }
}

/// Provider to allow UI components to consume and listen to the contact form state.
final contactFormProvider =
    StateNotifierProvider<ContactFormNotifier, ContactFormState>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return ContactFormNotifier(firestoreService);
});
