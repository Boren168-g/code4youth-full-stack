import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BackendService {
  // Your real hosted URL
  static const String baseUrl = 'https://code4youth-full-stack.onrender.com';

  Future<Map<String, dynamic>> getStatus() async {
    try {
      print('[Docker] Checking status at $baseUrl/api/status');
      final response = await http.get(Uri.parse('$baseUrl/api/status')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'Error', 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      print('[Docker] Status Error: $e');
      return {'status': 'Error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/user/$uid'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> syncUser({
    required String uid,
    required String name,
    required String email,
    String? grade,
    List<String>? interests,
    String? avatar,
    String? guardianEmail,
    String? consentStatus,
    String? languageCode,
    int? xp,
    int? streakDays,
    List<String>? completedLessons,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/user/sync');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'uid': uid,
          'name': name,
          'email': email,
          'grade': grade,
          'interests': interests ?? [],
          'avatar': avatar,
          'guardian_email': guardianEmail,
          'consent_status': consentStatus,
          'language_code': languageCode,
          'xp': xp ?? 0,
          'streak_days': streakDays ?? 0,
          'completed_lessons': completedLessons ?? [],
          'history': history ?? [],
        }),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      print('[Docker] Sync Error: $e');
      return false;
    }
  }
}
