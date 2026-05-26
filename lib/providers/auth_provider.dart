import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isInitialized = false;
  String? errorMessage;
  String? token;
  Map<String, dynamic>? user;
  String? avatarPath;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    token = await _api.getToken();
    user = await _api.getSavedUser();
    avatarPath = await _api.getSavedAvatarPath();
    await _applySavedProfileOverride();
    isInitialized = true;
    notifyListeners();
  }

  Map<String, dynamic>? _extractUserMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directUser = payload['user'];
      if (directUser is Map<String, dynamic>) return directUser;

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final nestedUser = data['user'];
        if (nestedUser is Map<String, dynamic>) return nestedUser;

        final hasProfileFields =
            data.containsKey('name') ||
            data.containsKey('email') ||
            data.containsKey('phone') ||
            data.containsKey('age');
        if (hasProfileFields) return data;
      }

      final hasProfileFields =
          payload.containsKey('name') ||
          payload.containsKey('email') ||
          payload.containsKey('phone') ||
          payload.containsKey('age');
      if (hasProfileFields) return payload;
    }
    return null;
  }

  Future<void> _refreshUserFromProfile({Map<String, dynamic>? fallback}) async {
    try {
      final profile = await _api.getProfile();
      final freshUser = _extractUserMap(profile);
      if (freshUser != null) {
        user = freshUser;
        await _api.saveUser(freshUser);
        await _applySavedProfileOverride();
        return;
      }
    } catch (_) {}

    if (fallback != null) {
      user = fallback;
      await _api.saveUser(fallback);
      await _applySavedProfileOverride();
    }
  }

  Future<void> _applySavedProfileOverride() async {
    final email = user?['email']?.toString();
    final override = await _api.getProfileOverride(email);
    if (override == null) return;

    user = {
      ...?user,
      ...override,
    };
    await _api.saveUser(user!);

    final savedAvatarPath = override['avatar_path']?.toString();
    if (savedAvatarPath != null && savedAvatarPath.isNotEmpty) {
      avatarPath = savedAvatarPath;
      await _api.saveAvatarPath(savedAvatarPath);
    }
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
    String confirm,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.register(name, email, password);
      final hasToken =
          data['token'] != null ||
          data['access_token'] != null ||
          data['data']?['token'] != null ||
          data['data']?['access_token'] != null;

      if (data['success'] == true || hasToken) {
        token = await _api.getToken();
        await _refreshUserFromProfile(
          fallback: _extractUserMap(data) ?? await _api.getSavedUser(),
        );
        if (token != null && token!.isNotEmpty) {
          notifyListeners();
          return true;
        }
      }
      errorMessage = _extractError(data);
      return false;
    } catch (_) {
      errorMessage = 'Tidak bisa terhubung ke server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.login(email, password);
      if (data['success'] == true || data['token'] != null) {
        token = await _api.getToken();
        avatarPath = await _api.getSavedAvatarPath();
        await _refreshUserFromProfile(
          fallback: _extractUserMap(data) ?? await _api.getSavedUser(),
        );
        if (token != null && token!.isNotEmpty) {
          notifyListeners();
          return true;
        }
      }
      errorMessage = _extractError(data);
      return false;
    } catch (_) {
      errorMessage = 'Tidak bisa terhubung ke server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final googleUser = await _authService.signInWithGoogle();
      if (googleUser == null) {
        errorMessage = 'Login Google dibatalkan.';
        return false;
      }

      final data = await _api.loginWithGoogle(
        idToken: googleUser.idToken,
        email: googleUser.email,
        name: googleUser.name,
        photoUrl: googleUser.photoUrl,
      );

      if (data['success'] == true || data['token'] != null) {
        token = await _api.getToken();
        avatarPath = googleUser.photoUrl ?? await _api.getSavedAvatarPath();
        await _refreshUserFromProfile(
          fallback:
              _extractUserMap(data) ??
              {
                'name': googleUser.name,
                'email': googleUser.email,
                'avatar': googleUser.photoUrl,
              },
        );

        if (avatarPath != null && avatarPath!.isNotEmpty) {
          await _api.saveAvatarPath(avatarPath!);
        }

        if (token != null && token!.isNotEmpty) {
          notifyListeners();
          return true;
        }
      }

      errorMessage = _extractError(data);
      return false;
    } catch (_) {
      errorMessage = 'Tidak bisa login dengan Google saat ini.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.updateProfile(data);
      if (result['success'] == true ||
          result['data'] != null ||
          result['user'] != null) {
        final updatedUser = {
          ...?user,
          ...data,
          ...?_extractUserMap(result),
        };
        await _refreshUserFromProfile(fallback: updatedUser);
        if (user != null) {
          await _api.saveProfileOverride({
            ...user!,
            if (avatarPath != null && avatarPath!.isNotEmpty)
              'avatar_path': avatarPath,
          });
        }
        notifyListeners();
        return true;
      }
      errorMessage = _extractError(result);
      return false;
    } catch (_) {
      errorMessage = 'Tidak bisa memperbarui profil saat ini.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setProfilePhoto(String path) async {
    avatarPath = path;
    await _api.saveAvatarPath(path);
    if (user != null) {
      await _api.saveProfileOverride({
        ...user!,
        'avatar_path': path,
      });
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    await _api.logout();
    token = null;
    user = null;
    avatarPath = null;
    notifyListeners();
  }

  String _extractError(Map<String, dynamic> data) {
    if (data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }

    if (data['errors'] is Map<String, dynamic>) {
      final errors = data['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
    }

    return 'Terjadi kesalahan.';
  }
}
