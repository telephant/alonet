import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String provider;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['user_metadata']?['full_name'] ?? json['user_metadata']?['name'] ?? '',
      avatarUrl: json['user_metadata']?['avatar_url'],
      provider: json['user_metadata']?['provider'] ?? 'email',
    );
  }
}

class AuthService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:3000/api'; // Update this for production
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Configure Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Add client ID for iOS (will be overridden by GoogleService-Info.plist if present)
    clientId: '921607312077-stvu569k9fh4abmoj7f523mejqr62spq.apps.googleusercontent.com',
  );

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Initialize auth service - check for existing session
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        // Verify token and get user profile
        final user = await _getUserProfile(token);
        if (user != null) {
          _setUser(user);
        } else {
          // Token is invalid, clear storage
          await _storage.deleteAll();
        }
      }
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final user = User.fromJson(data['user']);
        final session = data['session'];
        
        // Store tokens
        await _storage.write(key: 'access_token', value: session['access_token']);
        await _storage.write(key: 'refresh_token', value: session['refresh_token']);
        
        _setUser(user);
        return true;
      } else {
        _setError(data['error']['message'] ?? 'Sign up failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final session = data['session'];
        
        // Store tokens
        await _storage.write(key: 'access_token', value: session['access_token']);
        await _storage.write(key: 'refresh_token', value: session['refresh_token']);
        
        _setUser(user);
        return true;
      } else {
        _setError(data['error']['message'] ?? 'Sign in failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('🚀 Starting Google Sign-In process...');
      
      // Check if Google Play services are available (Android)
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          final isSignedIn = await _googleSignIn.isSignedIn();
          debugPrint('Google Play services - already signed in: $isSignedIn');
        } catch (e) {
          debugPrint('Google Play services check error: $e');
        }
      }

      debugPrint('🚀 About to call _googleSignIn.signIn()...');
      
      // Sign in with Google
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
      
      debugPrint('🚀 ===== googleAccount: $googleAccount');
      
      if (googleAccount == null) {
        debugPrint('🚀 Google sign-in was cancelled by user');
        _setError('Google sign-in was cancelled');
        _setLoading(false);
        return false;
      }

      debugPrint('🚀 Google sign-in successful, account: ${googleAccount.email}');
      
      // For now, just return false to test the sign-in process without backend call

      // // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _setError('Failed to get Google ID token');
        _setLoading(false);
        return false;
      }

      // Send ID token to our backend
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        
        // Store access token (simplified for OAuth)
        if (data['access_token'] != null) {
          await _storage.write(key: 'access_token', value: data['access_token']);
        }
        
        _setUser(user);
        return true;
      } else {
        _setError(data['error']['message'] ?? 'Google sign-in failed');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('🚀 Google sign-in error: $e');
      debugPrint('🚀 Stack trace: $stackTrace');
      
      String errorMessage = 'Google sign-in error: $e';
      
      if (e.toString().contains('PlatformException')) {
        errorMessage = 'Platform error during Google sign-in. Please check your configuration.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error during Google sign-in. Please check your internet connection.';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Sign out from Google if signed in
      if (_currentUser?.provider == 'google') {
        await _googleSignIn.signOut();
      }

      // Call backend signout (optional, as we'll clear local storage)
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        try {
          await http.post(
            Uri.parse('$_baseUrl/auth/signout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        } catch (e) {
          // Ignore backend signout errors, just clear local storage
          debugPrint('Backend signout error: $e');
        }
      }

      // Clear local storage
      await _storage.deleteAll();
      _setUser(null);
    } catch (e) {
      _setError('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile (for token verification)
  Future<User?> _getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      }
    } catch (e) {
      debugPrint('Get user profile error: $e');
    }
    return null;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final session = data['session'];
        
        // Update stored tokens
        await _storage.write(key: 'access_token', value: session['access_token']);
        await _storage.write(key: 'refresh_token', value: session['refresh_token']);
        
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
    return false;
  }
}