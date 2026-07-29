/// Matches backend `UserStatus` schema exactly: ACTIVE, OFFLINE, BUSY, ON_LEAVE
enum UserStatus {
  active('ACTIVE'),
  offline('OFFLINE'),
  busy('BUSY'),
  onLeave('ON_LEAVE');

  final String value;
  const UserStatus(this.value);

  /// Parse from the raw API string. Falls back to offline on unknown values
  /// so a bad/missing status never crashes the UI.
  static UserStatus fromString(String? raw) {
    return UserStatus.values.firstWhere(
      (s) => s.value == raw?.toUpperCase(),
      orElse: () => UserStatus.offline,
    );
  }

  bool get isLive => this == UserStatus.active;

  String get displayLabel {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.offline:
        return 'Offline';
      case UserStatus.busy:
        return 'Busy';
      case UserStatus.onLeave:
        return 'On Leave';
    }
  }
}