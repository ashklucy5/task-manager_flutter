/// Matches backend `TaskPriority` schema exactly: low, medium, high, urgent
enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String? raw) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == raw,
      orElse: () => TaskPriority.medium,
    );
  }

  String get displayLabel {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  /// Sort weight, highest priority first — useful for List.sort in
  /// task_list_provider.
  int get sortWeight {
    switch (this) {
      case TaskPriority.urgent:
        return 0;
      case TaskPriority.high:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 3;
    }
  }
}