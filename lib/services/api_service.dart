import 'dart:convert';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_configuredBaseUrl);
    }

    return _defaultBaseUrl;
  }

  static String get _defaultBaseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.166.125:8000/api';
    }

    return 'http://10.0.166.125:8000/api';
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getToken() async {
    return _getToken();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    return _saveUser(user);
  }

  Future<void> _saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  Future<void> saveAvatarPath(String path) async {
    return _saveAvatarPath(path);
  }

  Future<String?> getSavedAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatar_path');
  }

  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  String _profileOverrideKey(String email) =>
      'profile_override_${email.trim().toLowerCase()}';

  Future<void> saveProfileOverride(Map<String, dynamic> profile) async {
    final email = profile['email']?.toString();
    if (email == null || email.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileOverrideKey(email), jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getProfileOverride(String? email) async {
    if (email == null || email.trim().isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_profileOverrideKey(email));
    if (profileString == null) return null;

    final profile = jsonDecode(profileString);
    if (profile is Map<String, dynamic>) return profile;
    return null;
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('avatar_path');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'] ?? data['data']?['token'];
      final user = data['user'] ?? data['data']?['user'];

      if (token != null) {
        await _saveToken(token);
      }
      if (user != null) {
        await _saveUser(user);
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? phone,
    int? age,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
        'age': age,
      }),
    );

    final data = jsonDecode(response.body);

    final token =
        data['token'] ??
        data['access_token'] ??
        data['data']?['token'] ??
        data['data']?['access_token'];
    final user = data['user'] ?? data['data']?['user'];

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        (data['success'] == true || token != null)) {
      if (token != null) {
        await _saveToken(token);
      }
      if (user != null) {
        await _saveUser(user);
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    final payload = {
      'id_token': idToken,
      'email': email,
      'name': name,
      'avatar': photoUrl,
      'photo_url': photoUrl,
    };

    const endpoints = [
      'auth/google',
      'login/google',
      'google/login',
      'google-login',
    ];

    Map<String, dynamic>? lastData;

    for (final endpoint in endpoints) {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final data = _decodeMapResponse(response);
      lastData = data;

      if (_isAuthSuccess(response.statusCode, data)) {
        await _saveAuthData(data);
        return data;
      }

      if (!_isRouteNotFound(response.statusCode, data)) {
        return data;
      }
    }

    return lastData ??
        {
          'success': false,
          'message':
              'Route login Google tidak ditemukan di backend. Tambahkan endpoint /api/auth/google atau sesuaikan endpoint aplikasi.',
        };
  }

  Map<String, dynamic> _decodeMapResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
      };
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': data.toString()};
  }

  bool _isAuthSuccess(int statusCode, Map<String, dynamic> data) {
    final token =
        data['token'] ??
        data['access_token'] ??
        data['data']?['token'] ??
        data['data']?['access_token'];

    return (statusCode == 200 || statusCode == 201) &&
        (data['success'] == true || token != null);
  }

  bool _isRouteNotFound(int statusCode, Map<String, dynamic> data) {
    final message = data['message']?.toString().toLowerCase() ?? '';
    return statusCode == 404 &&
        (message.contains('route') ||
            message.contains('not found') ||
            message.contains('notfound'));
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final token =
        data['token'] ??
        data['access_token'] ??
        data['data']?['token'] ??
        data['data']?['access_token'];
    final user = data['user'] ?? data['data']?['user'];

    if (token != null) {
      await _saveToken(token);
    }
    if (user is Map<String, dynamic>) {
      await _saveUser(user);
    }
  }

  Future<void> logout() async {
    final headers = await _getHeaders();
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
    } catch (e, stackTrace) {
      debugPrint('Logout request failed: $e');
      debugPrint('$stackTrace');
    }
    await _clearData();
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getArticles() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/articles'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      final articles = data['data'] ?? data;
      if (articles is List) return articles;
      if (articles is Map<String, dynamic> && articles['data'] is List) {
        return articles['data'];
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> getArticleDetail(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/articles/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final article = data['data'] ?? data;
      if (article is Map<String, dynamic>) return article;
    }
    return {};
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    }
    return {};
  }

  Future<List<dynamic>> getCategories() async {
    return _getListFromEndpoint('categories');
  }

  Future<List<dynamic>> getTopicCategories() async {
    return _getListFromEndpoint('topic-categories');
  }

  Future<List<dynamic>> getDiseaseTopics({String? categorySlug}) async {
    if (categorySlug != null && categorySlug.isNotEmpty) {
      final queryItems = await _getListFromEndpoint(
        'topics?category=$categorySlug',
      );
      if (queryItems.isNotEmpty) return queryItems;

      return _getListFromEndpoint('topics/$categorySlug');
    }

    return _getListFromEndpoint('topics');
  }

  Future<Map<String, dynamic>> getDiseaseTopicDetail({
    required String categorySlug,
    required String topicSlug,
  }) async {
    final headers = await _getHeaders();
    final encodedCategory = Uri.encodeComponent(categorySlug);
    final encodedTopic = Uri.encodeComponent(topicSlug);

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/topics/$encodedCategory/$encodedTopic'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractMap(data);
      }
    } catch (e) {
      debugPrint('GET /topics/$categorySlug/$topicSlug failed: $e');
    }
    return {};
  }

  Future<List<dynamic>> _getListFromEndpoint(String endpoint) async {
    final headers = await _getHeaders();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractList(data);
      }
    } catch (e) {
      debugPrint('GET /$endpoint failed: $e');
    }
    return [];
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final items =
          data['data'] ??
          data['topics'] ??
          data['topic_categories'] ??
          data['categories'] ??
          data['diseases'] ??
          data['penyakit'];

      if (items is List) return items;
      if (items is Map<String, dynamic>) {
        if (items['data'] is List) return items['data'];
        if (items['topics'] is List) return items['topics'];
      }
    }
    return [];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final item =
          data['data'] ??
          data['topic'] ??
          data['topics'] ??
          data['disease'] ??
          data['penyakit'];

      if (item is Map<String, dynamic>) return item;
      return data;
    }
    return {};
  }

  Future<List<dynamic>> getKeluhan() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/keluhan'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      return data['data'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> createKeluhan(
    String title,
    String description,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/keluhan'),
      headers: headers,
      body: jsonEncode({'title': title, 'description': description}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteKeluhan(dynamic id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/keluhan/$id'),
      headers: headers,
    );
    final success = response.statusCode >= 200 && response.statusCode < 300;

    if (response.body.isEmpty) {
      return {'success': success};
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      data['success'] ??= success;
      return data;
    }
    return {'success': success};
  }

  Future<List<dynamic>> getHistory() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      return data['data'] ?? [];
    }
    return [];
  }
}
