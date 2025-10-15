import 'package:mongo_dart/mongo_dart.dart';

enum RegistrationStatus {
  confirmed,
  waitlisted,
  checkedIn,
  cancelled;

  String get label {
    switch (this) {
      case RegistrationStatus.confirmed:
        return 'Confirmed';
      case RegistrationStatus.waitlisted:
        return 'Waitlisted';
      case RegistrationStatus.checkedIn:
        return 'Checked In';
      case RegistrationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case RegistrationStatus.confirmed:
        return 'Your registration is confirmed';
      case RegistrationStatus.waitlisted:
        return 'You are on the waitlist';
      case RegistrationStatus.checkedIn:
        return 'Successfully checked in';
      case RegistrationStatus.cancelled:
        return 'Registration cancelled';
    }
  }
}

class Registration {
  final ObjectId id;
  final ObjectId eventId;
  final ObjectId userId;
  final String eventTitle;
  final String userName;
  final String userEmail; // @nwu.ac.bd email
  final String? studentId; // Extracted from email
  final String? personalEmail; // Personal email address
  final String? phoneNumber;
  final String? batch;
  final String? section;
  final DateTime eventDate;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final DateTime? checkedInAt;
  final String qrCode; // Unique QR code for this registration
  final Map<String, dynamic>? additionalData;

  Registration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.userName,
    required this.userEmail,
    this.studentId,
    this.personalEmail,
    this.phoneNumber,
    this.batch,
    this.section,
    required this.eventDate,
    required this.status,
    required this.registeredAt,
    this.checkedInAt,
    required this.qrCode,
    this.additionalData,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: json['_id'] as ObjectId,
      eventId: json['eventId'] as ObjectId,
      userId: json['userId'] as ObjectId,
      eventTitle: json['eventTitle'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      studentId: json['studentId'] as String?,
      personalEmail: json['personalEmail'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      batch: json['batch'] as String?,
      section: json['section'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      status: RegistrationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => RegistrationStatus.confirmed,
      ),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      qrCode: json['qrCode'] as String,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'userId': userId,
      'eventTitle': eventTitle,
      'userName': userName,
      'userEmail': userEmail,
      'studentId': studentId,
      'personalEmail': personalEmail,
      'phoneNumber': phoneNumber,
      'batch': batch,
      'section': section,
      'eventDate': eventDate.toIso8601String(),
      'status': status.name,
      'registeredAt': registeredAt.toIso8601String(),
      'checkedInAt': checkedInAt?.toIso8601String(),
      'qrCode': qrCode,
      'additionalData': additionalData,
    };
  }

  bool get isConfirmed => status == RegistrationStatus.confirmed;
  bool get isWaitlisted => status == RegistrationStatus.waitlisted;
  bool get isCheckedIn => status == RegistrationStatus.checkedIn;
  bool get isCancelled => status == RegistrationStatus.cancelled;

  Registration copyWith({
    ObjectId? id,
    ObjectId? eventId,
    ObjectId? userId,
    String? eventTitle,
    String? userName,
    String? userEmail,
    String? studentId,
    String? personalEmail,
    String? phoneNumber,
    String? batch,
    String? section,
    DateTime? eventDate,
    RegistrationStatus? status,
    DateTime? registeredAt,
    DateTime? checkedInAt,
    String? qrCode,
    Map<String, dynamic>? additionalData,
  }) {
    return Registration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      eventTitle: eventTitle ?? this.eventTitle,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      studentId: studentId ?? this.studentId,
      personalEmail: personalEmail ?? this.personalEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      batch: batch ?? this.batch,
      section: section ?? this.section,
      eventDate: eventDate ?? this.eventDate,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      qrCode: qrCode ?? this.qrCode,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Generate unique QR code for registration
  static String generateQRCode(
    ObjectId registrationId,
    ObjectId eventId,
    ObjectId userId,
  ) {
    // Create a unique identifier that includes registration, event, and user IDs
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final combined =
        '${registrationId.oid}-${eventId.oid}-${userId.oid}-$timestamp';

    // Return a hash-like string for QR code (in production, use proper hashing)
    return combined.substring(0, 32).toUpperCase();
  }

  // Extract student ID from @nwu.ac.bd email format
  static String extractStudentId(String email) {
    if (email.contains('@nwu.ac.bd')) {
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty) {
        // Extract ID from format like "20232002010@nwu.ac.bd"
        final localPart = emailParts[0];
        // Check if local part is all digits (student ID)
        if (RegExp(r'^\d+$').hasMatch(localPart)) {
          return localPart;
        }
      }
    }
    return '';
  }

  // Validate @nwu.ac.bd email format
  static bool isValidNwuEmail(String email) {
    if (!email.endsWith('@nwu.ac.bd')) return false;

    final localPart = email.split('@')[0];
    // Check if email follows student_id@nwu.ac.bd format (numbers only)
    return RegExp(r'^\d+$').hasMatch(localPart);
  }
}
