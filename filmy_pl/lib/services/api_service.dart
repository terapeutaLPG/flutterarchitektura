import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../models/comment.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://serwer2651407.home.pl/api.php';

  static Future<Map<String, dynamic>> register(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?endpoint=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?endpoint=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<void> logout() async {
    final token = await AuthService.getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl?endpoint=logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await AuthService.logout();
  }

  static Future<List<Video>> getVideos() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl?endpoint=videos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (data['videos'] != null) {
      return (data['videos'] as List).map((v) => Video.fromJson(v)).toList();
    }
    throw Exception(data['error'] ?? 'Błąd pobierania filmów');
  }

  // ===== LAJKI =====
  static Future<Map<String, dynamic>> getLikeStatus(String filename) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl?endpoint=like&file=${Uri.encodeComponent(filename)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleLike(String filename) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl?endpoint=like&file=${Uri.encodeComponent(filename)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  // ===== KOMENTARZE =====
  static Future<List<Comment>> getComments(String filename) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(
          '$baseUrl?endpoint=comments&file=${Uri.encodeComponent(filename)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (data['comments'] != null) {
      return (data['comments'] as List)
          .map((c) => Comment.fromJson(c))
          .toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addComment(
      String filename, String content) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(
          '$baseUrl?endpoint=comments&file=${Uri.encodeComponent(filename)}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteComment(String filename, int commentId) async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse(
          '$baseUrl?endpoint=comments&file=${Uri.encodeComponent(filename)}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': commentId}),
    );
  }
}
