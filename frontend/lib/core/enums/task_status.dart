/// Matches backend `TaskStatus` schema exactly:
/// pending, in_progress, completed, on_hold, overdue, cancelled
enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  onHold('on_hold'),
  overdue('overdue'),
  cancelled('cancelled');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String? raw) {
    return TaskStatus.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => TaskStatus.pending,
    );
  }

  String get displayLabel {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.overdue:
        return 'Overdue';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal => this == TaskStatus.completed || this == TaskStatus.cancelled;
}