import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BackendService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/status')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'Error', 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
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
      print('Error fetching profile from Docker: $e');
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
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/user/sync');
      final body = json.encode({
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
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('[Docker] Sync Error: $e');
      return false;
    }
  }
}
