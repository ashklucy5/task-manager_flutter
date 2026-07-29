/// Matches backend role pattern `^(super_admin|admin|member)$`.
/// Product-terms mapping: super_admin = CEO, admin = HR, member = Team.
enum UserRole {
  superAdmin('super_admin'),
  admin('admin'),
  member('member');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? raw) {
    return UserRole.values.firstWhere(
      (r) => r.value == raw,
      orElse: () => UserRole.member,
    );
  }

  /// Product-facing label (CEO/HR/Team), not the raw backend role name.
  String get displayLabel {
    switch (this) {
      case UserRole.superAdmin:
        return 'CEO';
      case UserRole.admin:
        return 'HR';
      case UserRole.member:
        return 'Team';
    }
  }

  bool get canAssignHrAndTeam => this == UserRole.superAdmin;
  bool get canAssignTeamOnly => this == UserRole.admin;
  bool get canViewFinancials => this == UserRole.superAdmin;
  bool get canViewAnalytics => this == UserRole.superAdmin;
  bool get canViewAllCompanyTasks => this == UserRole.superAdmin;
  bool get canViewOwnTeamTasksOnly => this == UserRole.admin;
}