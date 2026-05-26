import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.idToken,
    required this.email,
    this.name,
    this.photoUrl,
  });

  final String idToken;
  final String email;
  final String? name;
  final String? photoUrl;
}

class AuthService {
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '880050187387-ovr3ns1tfflbr08cjp4vt4m2tjb0k1q6.apps.googleusercontent.com',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? googleClientId : null,
    serverClientId: googleClientId,
    scopes: const ['email', 'profile'],
  );

  Future<GoogleAuthResult?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google tidak mengembalikan ID token.');
      }

      return GoogleAuthResult(
        idToken: idToken,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } catch (e) {
      debugPrint('Error pada Google Sign In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
