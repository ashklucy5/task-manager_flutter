import '../../../core/enums/user_role.dart';
import '../../../core/enums/user_status.dart';

/// Merges UserResponse (hierarchy: role, parent_id) with UserProfile
/// (live presence: is_online, last_seen, capacity) into one model —
/// the backend doesn't expose both in a single endpoint, so the
/// repository combines them.
class TeamMemberModel {
  final String id;
  final String fullName;
  final UserRole role;
  final String? parentId;
  final String? position;
  final UserStatus status;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final int? capacity;

  const TeamMemberModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.parentId,
    this.position,
    required this.status,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeen,
    this.capacity,
  });

  String get lastSeenLabel {
    if (isOnline) return 'Active now';
    if (lastSeen == null) return '—';
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 1) return 'Active just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours}h ago';
    return 'Active ${diff.inDays}d ago';
  }
}