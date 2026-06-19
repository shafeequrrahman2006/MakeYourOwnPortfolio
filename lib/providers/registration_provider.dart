import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/portfolio_request.dart';
import 'firebase_provider.dart';

enum SubmissionStatus { idle, loading, success, error }

class RegistrationState {
  final int currentStep; // 0 to 4 (Step 1 to 5)
  
  // Step 1 Fields
  final String fullName;
  final String whatsapp;
  final String email;
  final String? fullNameError;
  final String? whatsappError;
  final String? emailError;

  // Step 2 Fields
  final String status; // Student / Fresher / Professional
  final String desiredRole;
  final String? desiredRoleError;

  // Step 3 Fields
  final Uint8List? resumeBytes;
  final String? resumeFileName;
  final double uploadProgress; // 0.0 to 1.0
  final bool isUploading;
  final String? resumeError;

  // Step 4 Fields
  final String selectedPackage; // Student / Professional

  // Step 5 Fields (Confirmation & Submission)
  final SubmissionStatus submissionStatus;
  final String? submissionError;
  final PortfolioRequest? submittedRequest;

  RegistrationState({
    this.currentStep = 0,
    this.fullName = '',
    this.whatsapp = '',
    this.email = '',
    this.fullNameError,
    this.whatsappError,
    this.emailError,
    this.status = 'Student',
    this.desiredRole = '',
    this.desiredRoleError,
    this.resumeBytes,
    this.resumeFileName,
    this.uploadProgress = 0.0,
    this.isUploading = false,
    this.resumeError,
    this.selectedPackage = 'Professional', // Default to Professional (Most popular)
    this.submissionStatus = SubmissionStatus.idle,
    this.submissionError,
    this.submittedRequest,
  });

  RegistrationState copyWith({
    int? currentStep,
    String? fullName,
    String? whatsapp,
    String? email,
    String? fullNameError,
    String? whatsappError,
    String? emailError,
    String? status,
    String? desiredRole,
    String? desiredRoleError,
    Uint8List? resumeBytes,
    String? resumeFileName,
    double? uploadProgress,
    bool? isUploading,
    String? resumeError,
    String? selectedPackage,
    SubmissionStatus? submissionStatus,
    String? submissionError,
    PortfolioRequest? submittedRequest,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      fullNameError: fullNameError, // Pass null to clear error
      whatsappError: whatsappError,
      emailError: emailError,
      status: status ?? this.status,
      desiredRole: desiredRole ?? this.desiredRole,
      desiredRoleError: desiredRoleError,
      resumeBytes: resumeBytes ?? this.resumeBytes,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploading: isUploading ?? this.isUploading,
      resumeError: resumeError ?? this.resumeError,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionError: submissionError ?? this.submissionError,
      submittedRequest: submittedRequest ?? this.submittedRequest,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final FirebaseService _firebaseService;

  RegistrationNotifier(this._firebaseService) : super(RegistrationState());

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updateFullName(String value) {
    state = state.copyWith(
      fullName: value,
      fullNameError: null,
    );
  }

  void updateWhatsapp(String value) {
    state = state.copyWith(
      whatsapp: value,
      whatsappError: null,
    );
  }

  void updateEmail(String value) {
    state = state.copyWith(
      email: value,
      emailError: null,
    );
  }

  void updateStatus(String value) {
    state = state.copyWith(status: value);
  }

  void updateDesiredRole(String value) {
    state = state.copyWith(
      desiredRole: value,
      desiredRoleError: null,
    );
  }

  void selectPackage(String value) {
    state = state.copyWith(selectedPackage: value);
  }

  bool validateStep1() {
    bool isValid = true;
    String? nameErr;
    String? phoneErr;
    String? emailErr;

    if (state.fullName.trim().isEmpty) {
      nameErr = 'Full Name is required';
      isValid = false;
    }

    final phonePattern = RegExp(r'^\+?[0-9\s\-]{8,15}$');
    if (state.whatsapp.trim().isEmpty) {
      phoneErr = 'WhatsApp Number is required';
      isValid = false;
    } else if (!phonePattern.hasMatch(state.whatsapp)) {
      phoneErr = 'Enter a valid phone number (e.g. +91 9876543210)';
      isValid = false;
    }

    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (state.email.trim().isEmpty) {
      emailErr = 'Email Address is required';
      isValid = false;
    } else if (!emailPattern.hasMatch(state.email)) {
      emailErr = 'Enter a valid email address';
      isValid = false;
    }

    state = state.copyWith(
      fullNameError: nameErr,
      whatsappError: phoneErr,
      emailError: emailErr,
    );

    return isValid;
  }

  bool validateStep2() {
    bool isValid = true;
    String? roleErr;

    if (state.desiredRole.trim().isEmpty) {
      roleErr = 'Desired Role is required';
      isValid = false;
    }

    state = state.copyWith(
      desiredRoleError: roleErr,
    );

    return isValid;
  }

  bool validateStep3() {
    if (state.resumeBytes == null) {
      state = state.copyWith(resumeError: 'Please upload a resume to proceed');
      return false;
    }
    state = state.copyWith(resumeError: null);
    return true;
  }

  void nextStep() {
    if (state.currentStep == 0) {
      if (validateStep1()) {
        state = state.copyWith(currentStep: 1);
      }
    } else if (state.currentStep == 1) {
      if (validateStep2()) {
        state = state.copyWith(currentStep: 2);
      }
    } else if (state.currentStep == 2) {
      if (validateStep3()) {
        state = state.copyWith(currentStep: 3);
      }
    } else if (state.currentStep == 3) {
      state = state.copyWith(currentStep: 4);
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> pickResume() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // Crucial for Flutter Web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validation: Maximum file size 10MB
        final double sizeInMb = file.size / (1024 * 1024);
        if (sizeInMb > 10.0) {
          state = state.copyWith(resumeError: 'File size exceeds the 10MB limit.');
          return;
        }

        final bytes = file.bytes;
        final name = file.name;

        if (bytes != null) {
          // Clear error and trigger uploading state
          state = state.copyWith(
            resumeError: null,
            isUploading: true,
            uploadProgress: 0.0,
            resumeBytes: null,
            resumeFileName: null,
          );

          // Simulate animated upload progress
          double progress = 0.0;
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
            progress += 0.08;
            if (progress >= 1.0) {
              progress = 1.0;
              timer.cancel();
              state = state.copyWith(
                isUploading: false,
                uploadProgress: 1.0,
                resumeBytes: bytes,
                resumeFileName: name,
              );
            } else {
              state = state.copyWith(uploadProgress: progress);
            }
          });
        }
      }
    } catch (e) {
      state = state.copyWith(resumeError: 'Failed to pick file: $e');
    }
  }

  void removeResume() {
    state = state.copyWith(
      resumeBytes: null,
      resumeFileName: null,
      uploadProgress: 0.0,
      resumeError: null,
    );
  }

  Future<void> submitRegistration() async {
    if (state.submissionStatus == SubmissionStatus.loading) return;

    state = state.copyWith(
      submissionStatus: SubmissionStatus.loading,
      submissionError: null,
    );

    try {
      final request = await _firebaseService.submitRequest(
        fullName: state.fullName,
        whatsapp: state.whatsapp,
        email: state.email,
        status: state.status,
        desiredRole: state.desiredRole,
        selectedPackage: state.selectedPackage,
        resumeBytes: state.resumeBytes,
        resumeFileName: state.resumeFileName,
      );

      state = state.copyWith(
        submissionStatus: SubmissionStatus.success,
        submittedRequest: request,
      );
    } catch (e) {
      state = state.copyWith(
        submissionStatus: SubmissionStatus.error,
        submissionError: e.toString(),
      );
    }
  }

  void resetForm() {
    state = RegistrationState();
  }
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return RegistrationNotifier(firebaseService);
});
