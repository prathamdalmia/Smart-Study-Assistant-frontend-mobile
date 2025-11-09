import 'dart:convert';
import 'package:http/http.dart' as http;

// Default base URL (set to the project's deployed backend)
String _baseUrl =
    'https://smartstudyassistantbackend-abdwc2fkdzhybncn.uaenorth-01.azurewebsites.net/api';
String? _token;

void setBaseUrl(String url) {
  _baseUrl = url;
}

void setToken(String token) {
  _token = token;
}

void clearToken() {
  _token = null;
}

Map<String, String> _headers([Map<String, String>? extra]) {
  final headers = <String, String>{'Content-Type': 'application/json'};
  if (_token != null) headers['Authorization'] = 'Bearer $_token';
  if (extra != null) headers.addAll(extra);
  return headers;
}

class ApiService {
  // Auth
  static Future<Map<String, dynamic>> login(
      String emailOrUsername, String password, {bool isAdmin = false}) async {
    final res = await http.post(Uri.parse('$_baseUrl/auth/login'),
        headers: _headers(),
        body: jsonEncode({
          'emailOrUsername': emailOrUsername,
          'password': password,
          'isAdmin': isAdmin,
        }));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${res.body}');
  }

  static Future<Map<String, dynamic>> signup(
      String name, String username, String email, String password) async {
    final res = await http.post(Uri.parse('$_baseUrl/auth/signup'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password
        }));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Signup failed: ${res.body}');
  }

  // Notes
  static Future<List<dynamic>> getNotes() async {
    final res =
        await http.get(Uri.parse('$_baseUrl/notes'), headers: _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch notes');
  }

  static Future<Map<String, dynamic>> createNote(
      Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_baseUrl/notes/create'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create note');
  }

  static Future<Map<String, dynamic>> uploadNote(
      List<int> fileBytes, String fileName) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/notes/upload'),
    );
    request.headers.addAll(_headers());
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to upload note');
  }

  // Get file URL from file path
  static String getFileUrl(String filePath) {
    // Extract base URL without /api
    final baseUrlWithoutApi = _baseUrl.replaceAll('/api', '');
    // Remove 'uploads/' prefix if present
    final cleanPath = filePath.startsWith('uploads/') 
        ? filePath 
        : 'uploads/$filePath';
    return '$baseUrlWithoutApi/$cleanPath';
  }

  // Tasks
  static Future<List<dynamic>> getTasks() async {
    final res =
        await http.get(Uri.parse('$_baseUrl/tasks'), headers: _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch tasks');
  }

  static Future<Map<String, dynamic>> addTask(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_baseUrl/tasks'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to add task');
  }

  static Future<Map<String, dynamic>> updateTask(
      String id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_baseUrl/tasks/$id'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update task');
  }

  // AI
  static Future<Map<String, dynamic>> aiChat(String message) async {
    final res = await http.post(Uri.parse('$_baseUrl/ai/chat'),
        headers: _headers(), body: jsonEncode({'message': message}));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('AI chat failed');
  }

  static Future<Map<String, dynamic>> summarize(String text) async {
    final res = await http.post(Uri.parse('$_baseUrl/ai/summarize'),
        headers: _headers(), body: jsonEncode({'text': text}));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Summarize failed');
  }

  static Future<Map<String, dynamic>> quiz(String text) async {
    final res = await http.post(Uri.parse('$_baseUrl/ai/quiz'),
        headers: _headers(), body: jsonEncode({'text': text}));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Quiz failed');
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    final res =
        await http.get(Uri.parse('$_baseUrl/analytics'), headers: _headers());
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to fetch analytics');
  }

  static Future<Map<String, dynamic>> updateStudyTime(int studyTimeMinutes) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/analytics/study-time'),
      headers: _headers(),
      body: jsonEncode({'studyTimeMinutes': studyTimeMinutes}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update study time');
  }

  // Admin
  static Future<List<dynamic>> getAllStudents() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/admin/students'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch students');
  }

  static Future<void> deleteStudent(String studentId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/admin/students/$studentId'),
      headers: _headers(),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete student');
    }
  }
}
