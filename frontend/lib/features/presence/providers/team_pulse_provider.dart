import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/presence_repository.dart';
import '../models/team_member_model.dart';

final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  return PresenceRepository(ref.watch(dioProvider));
});

/// A section of the grouped team pulse list: a manager (or null for
/// "Unassigned") + their direct reports.
class TeamGroup {
  final TeamMemberModel? manager; // null = "Unassigned" bucket
  final List<TeamMemberModel> members;
  const TeamGroup({this.manager, required this.members});

  String get title => manager?.fullName ?? 'Unassigned';
}

/// Fetches and groups team members according to the viewer's role:
/// - CEO: sections per HR, each with their direct reports
/// - HR: flat list of their own direct reports
/// - Member: flat list of peers (same HR)
final teamPulseProvider = FutureProvider.autoDispose<List<TeamGroup>>((ref) async {
  final repository = ref.watch(presenceRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  final members = await repository.getTeamMembers();

  if (currentUser == null) return [];

  switch (currentUser.role) {
    case UserRole.superAdmin:
      final hrs = members.where((m) => m.role == UserRole.admin).toList();
      final groups = <TeamGroup>[];

      for (final hr in hrs) {
        final reports = members.where((m) => m.parentId == hr.id).toList();
        groups.add(TeamGroup(manager: hr, members: reports));
      }

      final assignedIds = {
        for (final g in groups) ...g.members.map((m) => m.id),
        ...hrs.map((h) => h.id),
      };
      final unassigned = members
          .where((m) => m.id != currentUser.id && !assignedIds.contains(m.id))
          .toList();
      if (unassigned.isNotEmpty) {
        groups.add(TeamGroup(manager: null, members: unassigned));
      }
      return groups;

    case UserRole.admin:
      final reports = members.where((m) => m.parentId == currentUser.id).toList();
      return [TeamGroup(manager: null, members: reports)];

    case UserRole.member:
      final peers = members
          .where((m) => m.parentId == currentUser.parentId && m.id != currentUser.id)
          .toList();
      return [TeamGroup(manager: null, members: peers)];
  }
});