class UserWithFinancials {
  final String id;
  final String fullName;
  final String role;
  final int? salary;
  final int? paymentRate;

  const UserWithFinancials({
    required this.id,
    required this.fullName,
    required this.role,
    this.salary,
    this.paymentRate,
  });

  factory UserWithFinancials.fromJson(Map<String, dynamic> json) {
    return UserWithFinancials(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      salary: json['salary'] as int?,
      paymentRate: json['payment_rate'] as int?,
    );
  }
}

class TaskWithFinancials {
  final int id;
  final String title;
  final String? clientName;
  final int? paymentAmount;
  final bool isPaid;
  final String status;

  const TaskWithFinancials({
    required this.id,
    required this.title,
    this.clientName,
    this.paymentAmount,
    required this.isPaid,
    required this.status,
  });

  factory TaskWithFinancials.fromJson(Map<String, dynamic> json) {
    return TaskWithFinancials(
      id: json['id'] as int,
      title: json['title'] as String,
      clientName: json['client_name'] as String?,
      paymentAmount: json['payment_amount'] as int?,
      isPaid: json['is_paid'] as bool? ?? false,
      status: json['status'] as String,
    );
  }
}

class FinancialSummary {
  final int companyId;
  final int totalUsers;
  final int activeUsers;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int totalPaymentCents;
  final String totalPaymentUsd;

  const FinancialSummary({
    required this.companyId,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.totalPaymentCents,
    required this.totalPaymentUsd,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      companyId: json['company_id'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
      totalPaymentCents: json['total_payment_cents'] as int? ?? 0,
      totalPaymentUsd: json['total_payment_usd'] as String? ?? '\$0.00',
    );
  }
}
