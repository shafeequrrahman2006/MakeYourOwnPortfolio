import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioRequest {
  final String requestId;
  final String fullName;
  final String whatsapp;
  final String email;
  final String status; // Student / Fresher / Professional
  final String desiredRole;
  final String selectedPackage; // Student / Professional
  final String resumeUrl;
  final String requestStatus; // Pending / Contacted / In Progress / Completed
  final DateTime createdAt;

  PortfolioRequest({
    required this.requestId,
    required this.fullName,
    required this.whatsapp,
    required this.email,
    required this.status,
    required this.desiredRole,
    required this.selectedPackage,
    required this.resumeUrl,
    this.requestStatus = 'Pending',
    required this.createdAt,
  });

  PortfolioRequest copyWith({
    String? requestId,
    String? fullName,
    String? whatsapp,
    String? email,
    String? status,
    String? desiredRole,
    String? selectedPackage,
    String? resumeUrl,
    String? requestStatus,
    DateTime? createdAt,
  }) {
    return PortfolioRequest(
      requestId: requestId ?? this.requestId,
      fullName: fullName ?? this.fullName,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      status: status ?? this.status,
      desiredRole: desiredRole ?? this.desiredRole,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      requestStatus: requestStatus ?? this.requestStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'fullName': fullName,
      'whatsapp': whatsapp,
      'email': email,
      'status': status,
      'desiredRole': desiredRole,
      'selectedPackage': selectedPackage,
      'resumeUrl': resumeUrl,
      'requestStatus': requestStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PortfolioRequest.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final dynamic rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      parsedDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else if (rawCreated is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    } else {
      parsedDate = DateTime.now();
    }

    return PortfolioRequest(
      requestId: map['requestId'] ?? '',
      fullName: map['fullName'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      desiredRole: map['desiredRole'] ?? '',
      selectedPackage: map['selectedPackage'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      requestStatus: map['requestStatus'] ?? 'Pending',
      createdAt: parsedDate,
    );
  }
}
