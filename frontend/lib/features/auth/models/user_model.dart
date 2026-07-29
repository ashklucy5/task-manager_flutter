import '../../../core/enums/user_role.dart';
import '../../../core/enums/user_status.dart';

/// Maps the backend UserResponse schema exactly.
class UserModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final UserRole role;
  final int companyId;
  final String? companyCode;
  final String? companyName;
  final String? parentId;
  final String? position;
  final UserStatus status;
  final String? avatarUrl;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    required this.companyId,
    this.companyCode,
    this.companyName,
    this.parentId,
    this.position,
    required this.status,
    this.avatarUrl,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromString(json['role'] as String?),
      companyId: json['company_id'] as int,
      companyCode: json['company_code'] as String?,
      companyName: json['company_name'] as String?,
      parentId: json['parent_id'] as String?,
      position: json['position'] as String?,
      status: UserStatus.fromString(json['status'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}