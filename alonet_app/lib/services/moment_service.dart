import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Moment {
  final String id;
  final String userId;
  final String event;
  final String? note;
  final DateTime momentTime;
  final String timezone;
  final String? reaction;
  final DateTime? reactedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Moment({
    required this.id,
    required this.userId,
    required this.event,
    this.note,
    required this.momentTime,
    required this.timezone,
    this.reaction,
    this.reactedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      event: json['event'] ?? '',
      note: json['note'],
      momentTime: DateTime.parse(json['moment_time']),
      timezone: json['timezone'] ?? 'UTC',
      reaction: json['reaction'],
      reactedAt: json['reacted_at'] != null
          ? DateTime.parse(json['reacted_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event': event,
      'note': note,
      'moment_time': momentTime.toIso8601String(),
      'timezone': timezone,
      'reaction': reaction,
      'reacted_at': reactedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MomentStats {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int userMomentsCount;
  final int partnerMomentsCount;
  final int totalMoments;
  final int reactedMoments;

  MomentStats({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.userMomentsCount,
    required this.partnerMomentsCount,
    required this.totalMoments,
    required this.reactedMoments,
  });

  factory MomentStats.fromJson(Map<String, dynamic> json) {
    return MomentStats(
      period: json['period'] ?? 'week',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      userMomentsCount: json['user_moments_count'] ?? 0,
      partnerMomentsCount: json['partner_moments_count'] ?? 0,
      totalMoments: json['total_moments'] ?? 0,
      reactedMoments: json['reacted_moments'] ?? 0,
    );
  }
}

class MomentService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  List<Moment> _userMoments = [];
  List<Moment> _partnerMoments = [];
  bool _isLoading = false;
  String? _error;

  List<Moment> get userMoments => _userMoments;
  List<Moment> get partnerMoments => _partnerMoments;
  List<Moment> get allMoments => [..._userMoments, ..._partnerMoments]
    ..sort((a, b) => a.momentTime.compareTo(b.momentTime));
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  /// Create a new moment
  Future<Moment?> createMoment({
    required String event,
    String? note,
    required DateTime momentTime,
    required String timezone,
  }) async {
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
        Uri.parse('$_baseUrl/moments'),
        headers: _buildHeaders(token),
        body: json.encode({
          'event': event,
          'note': note,
          'moment_time': momentTime.toIso8601String(),
          'timezone': timezone,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final moment = Moment.fromJson(data);
        _userMoments.add(moment);
        _userMoments.sort((a, b) => a.momentTime.compareTo(b.momentTime));
        notifyListeners();
        return moment;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to create moment');
        return null;
      }
    } catch (e) {
      debugPrint('Create moment error: $e');
      _setError('Network error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get moments with optional filters
  Future<void> getMoments({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return;
      }

      var url = '$_baseUrl/moments';
      final queryParams = <String, String>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userMoments = (data['user_moments'] as List)
            .map((m) => Moment.fromJson(m))
            .toList();
        _partnerMoments = (data['partner_moments'] as List)
            .map((m) => Moment.fromJson(m))
            .toList();
        notifyListeners();
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to fetch moments');
      }
    } catch (e) {
      debugPrint('Get moments error: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get moments for a specific date
  Future<void> getMomentsForDate(DateTime date) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return;
      }

      final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final response = await http.get(
        Uri.parse('$_baseUrl/moments/date/$dateStr'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userMoments = (data['user_moments'] as List)
            .map((m) => Moment.fromJson(m))
            .toList();
        _partnerMoments = (data['partner_moments'] as List)
            .map((m) => Moment.fromJson(m))
            .toList();
        notifyListeners();
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to fetch moments for date');
      }
    } catch (e) {
      debugPrint('Get moments for date error: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update a moment (only for owner)
  Future<bool> updateMoment({
    required String momentId,
    String? event,
    String? note,
    DateTime? momentTime,
    String? timezone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return false;
      }

      final updateData = <String, dynamic>{};
      if (event != null) updateData['event'] = event;
      if (note != null) updateData['note'] = note;
      if (momentTime != null) updateData['moment_time'] = momentTime.toIso8601String();
      if (timezone != null) updateData['timezone'] = timezone;

      final response = await http.put(
        Uri.parse('$_baseUrl/moments/$momentId'),
        headers: _buildHeaders(token),
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedMoment = Moment.fromJson(data);

        // Update in local list
        final index = _userMoments.indexWhere((m) => m.id == momentId);
        if (index != -1) {
          _userMoments[index] = updatedMoment;
          _userMoments.sort((a, b) => a.momentTime.compareTo(b.momentTime));
          notifyListeners();
        }
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to update moment');
        return false;
      }
    } catch (e) {
      debugPrint('Update moment error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a moment (only for owner)
  Future<bool> deleteMoment(String momentId) async {
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
        Uri.parse('$_baseUrl/moments/$momentId'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        _userMoments.removeWhere((m) => m.id == momentId);
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to delete moment');
        return false;
      }
    } catch (e) {
      debugPrint('Delete moment error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// React to a partner's moment
  Future<bool> reactToMoment(String momentId, String? reaction) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return false;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/moments/$momentId/react'),
        headers: _buildHeaders(token),
        body: json.encode({'reaction': reaction}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedMoment = Moment.fromJson(data);

        // Update in partner moments list
        final index = _partnerMoments.indexWhere((m) => m.id == momentId);
        if (index != -1) {
          _partnerMoments[index] = updatedMoment;
          notifyListeners();
        }
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to react to moment');
        return false;
      }
    } catch (e) {
      debugPrint('React to moment error: $e');
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get moment statistics
  Future<MomentStats?> getMomentStats({String period = 'week'}) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Not authenticated');
        _setLoading(false);
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/moments/stats?period=$period'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MomentStats.fromJson(data);
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to fetch moment stats');
        return null;
      }
    } catch (e) {
      debugPrint('Get moment stats error: $e');
      _setError('Network error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all moments
  void clear() {
    _userMoments.clear();
    _partnerMoments.clear();
    _error = null;
    notifyListeners();
  }
}
