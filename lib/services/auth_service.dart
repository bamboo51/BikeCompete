import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final int id;
  final String name;
  final String email;
  const AuthUser({required this.id, required this.name, required this.email});
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'auth_user';

  // Pass at build time: --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static const _webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  // Pass at build time: --dart-define=API_BASE_URL=http://PI_IP:5000
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  final _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId.isNotEmpty ? _webClientId : null,
  );

  String? _token;
  AuthUser? _user;

  String? get token => _token;
  AuthUser? get user => _user;
  bool get isLoggedIn => _token != null;

  /// Load persisted token + user on app start. Call once in main().
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      _user = AuthUser(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
      );
    }
  }

  /// Trigger Google Sign-In, send the ID token to the backend, store the JWT.
  Future<AuthUser> signInWithGoogle() async {
    assert(_webClientId.isNotEmpty, 'GOOGLE_WEB_CLIENT_ID is not set — rebuild with --dart-define=GOOGLE_WEB_CLIENT_ID=...');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw 'Sign-in cancelled.';

    final auth = await googleUser.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw 'Failed to get ID token from Google.';

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode != 200) {
      throw 'Backend auth failed (${response.statusCode}): ${response.body}';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final ud = data['user'] as Map<String, dynamic>;

    _token = token;
    _user = AuthUser(
      id: ud['id'] as int,
      name: ud['name'] as String,
      email: ud['email'] as String,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(
      _userKey,
      jsonEncode({'id': _user!.id, 'name': _user!.name, 'email': _user!.email}),
    );

    return _user!;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
