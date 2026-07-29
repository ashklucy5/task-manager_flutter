import 'package:dio/dio.dart';
import 'package:nexusflow_ai/core/network/dio_client.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/user_status.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/team_member_model.dart';

class PresenceRepository {
  final Dio _dio;
  PresenceRepository(this._dio);

  /// POST /users/me/heartbeat — silent, called every 5s while the app
  /// is foregrounded. Updates last_seen only, not status.
  Future<void> sendHeartbeat() async {
    try {
      await _dio.post(ApiEndpoints.heartbeat);
    } on DioException {
      // Best-effort — a single missed heartbeat shouldn't crash anything.
    }
  }

  /// PUT /users/me/status — explicit user-driven status change.
  Future<void> updateStatus(UserStatus status) async {
    try {
      await _dio.put(ApiEndpoints.updateStatus, queryParameters: {'new_status': status.value});
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<void> setOffline() async {
    try {
      await _dio.post(ApiEndpoints.setOffline);
    } on DioException {
      // best-effort, e.g. called on app dispose — don't block on failure
    }
  }

  /// Merges GET /users/ (hierarchy: role, parent_id, position) with
  /// GET /users/team-profiles (live presence: is_online, last_seen,
  /// capacity) into one list, matched by id. This is what
  /// team_pulse_provider groups into sections.
  Future<List<TeamMemberModel>> getTeamMembers() async {
    try {
      final results = await Future.wait([
        _dio.get(ApiEndpoints.usersList),
        _dio.get(ApiEndpoints.teamProfiles),
      ]);

      final users = results[0].data as List;
      final profiles = results[1].data as List;

      final profileById = {
        for (final p in profiles) p['id'] as String: p as Map<String, dynamic>,
      };

      return users.map((u) {
        final userJson = u as Map<String, dynamic>;
        final id = userJson['id'] as String;
        final profile = profileById[id];

        return TeamMemberModel(
          id: id,
          fullName: userJson['full_name'] as String,
          role: UserRole.fromString(userJson['role'] as String?),
          parentId: userJson['parent_id'] as String?,
          position: userJson['position'] as String?,
          status: UserStatus.fromString(profile?['status'] as String? ?? userJson['status'] as String?),
          avatarUrl: (profile?['avatar_url'] ?? userJson['avatar_url']) as String?,
          isOnline: profile?['is_online'] as bool? ?? false,
          lastSeen: profile?['last_seen'] != null ? DateTime.parse(profile!['last_seen'] as String) : null,
          capacity: profile?['capacity'] as int?,
        );
      }).toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}