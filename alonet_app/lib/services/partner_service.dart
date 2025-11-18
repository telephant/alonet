import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Partner {
  final String id;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? avatarUrlExternal;
  final String provider;

  Partner({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.avatarUrlExternal,
    required this.provider,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      avatarUrlExternal: json['avatar_url_external'],
      provider: json['provider'] ?? 'email',
    );
  }
}

class PartnerRelationship {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  PartnerRelationship({
    required this.id,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory PartnerRelationship.fromJson(Map<String, dynamic> json) {
    return PartnerRelationship(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
    );
  }
}

class Invitation {
  final String invitationCode;
  final String status;
  final DateTime createdAt;

  Invitation({
    required this.invitationCode,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      invitationCode: json['invitation_code'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PartnerService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Partner? _currentPartner;
  PartnerRelationship? _relationship;
  Invitation? _currentInvitation;
  bool _isLoading = false;
  String? _error;

  Partner? get currentPartner => _currentPartner;
  PartnerRelationship? get relationship => _relationship;
  Invitation? get currentInvitation => _currentInvitation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPartner => _currentPartner != null && _relationship?.status == 'accepted';

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Send a partner invitation and get invitation code
  Future<Invitation?> sendInvitation() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return null;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/partners/invite'),
        headers: _buildHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _currentInvitation = Invitation.fromJson(data);
        notifyListeners();
        return _currentInvitation;
      } else {
        _setError(data['error'] ?? 'Failed to send invitation');
        return null;
      }
    } catch (e) {
      debugPrint('Send invitation error: $e');
      _setError('Network error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Accept a partner invitation using invitation code
  Future<bool> acceptInvitation(String invitationCode) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/partners/accept'),
        headers: _buildHeaders(token),
        body: json.encode({'invitation_code': invitationCode}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentPartner = Partner.fromJson(data['partner']);
        _relationship = PartnerRelationship.fromJson(data['relationship']);
        notifyListeners();
        return true;
      } else {
        _setError(data['error'] ?? 'Failed to accept invitation');
        return false;
      }
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get current partner information
  Future<void> getCurrentPartner() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/partners/current'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentPartner = Partner.fromJson(data['partner']);
        _relationship = PartnerRelationship.fromJson(data['relationship']);
        notifyListeners();
      } else if (response.statusCode == 404) {
        // No partner found - this is okay
        _currentPartner = null;
        _relationship = null;
        notifyListeners();
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to get partner');
      }
    } catch (e) {
      debugPrint('Get current partner error: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove current partner
  Future<bool> removePartner() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/partners/current'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        _currentPartner = null;
        _relationship = null;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to remove partner');
        return false;
      }
    } catch (e) {
      debugPrint('Remove partner error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel pending invitation
  Future<bool> cancelInvitation() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/partners/invite'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        _currentInvitation = null;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to cancel invitation');
        return false;
      }
    } catch (e) {
      debugPrint('Cancel invitation error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all partner data
  void clear() {
    _currentPartner = null;
    _relationship = null;
    _currentInvitation = null;
    _error = null;
    notifyListeners();
  }
}
