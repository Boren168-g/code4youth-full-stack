import 'package:flutter/foundation.dart';

enum ConsentStatus { notRequired, pending, granted }

@immutable
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.grade,
    required this.interests,
    this.avatar = '🦊',
    this.guardianEmail,
    this.consent = ConsentStatus.notRequired,
    this.languageCode = 'en',
  });

  final String displayName;
  final String email;
  final String grade;
  final List<String> interests;
  final String avatar;
  final String? guardianEmail;
  final ConsentStatus consent;
  final String languageCode;

  bool get isMinor => grade != 'University';
  bool get isActivated => consent == ConsentStatus.notRequired || consent == ConsentStatus.granted;

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'grade': grade,
      'interests': interests,
      'avatar': avatar,
      'guardianEmail': guardianEmail,
      'consent': consent.name,
      'languageCode': languageCode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      grade: map['grade'] as String,
      interests: List<String>.from(map['interests'] as List? ?? []),
      avatar: map['avatar'] as String? ?? '🦊',
      guardianEmail: map['guardianEmail'] as String?,
      consent: ConsentStatus.values.byName(map['consent'] as String? ?? 'notRequired'),
      languageCode: map['languageCode'] as String? ?? 'en',
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? grade,
    List<String>? interests,
    String? avatar,
    String? guardianEmail,
    ConsentStatus? consent,
    String? languageCode,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      interests: interests ?? this.interests,
      avatar: avatar ?? this.avatar,
      guardianEmail: guardianEmail ?? this.guardianEmail,
      consent: consent ?? this.consent,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
