import 'token_model.dart';
import 'user_model.dart';

/// Maps the backend's CompanyWithAdminResponse — company + admin + token
/// all in one response from POST /companies/with-admin. Only the pieces
/// the app actually needs right now are pulled out: the token (to log
/// the new CEO in immediately) and the admin user (so there's no need
/// for a follow-up /users/me call). companyCode/companyName are kept
/// too in case a post-registration screen wants to show them.
class CompanyWithAdminResult {
  final TokenModel token;
  final UserModel admin;
  final String companyName;
  final String companyCode;

  const CompanyWithAdminResult({
    required this.token,
    required this.admin,
    required this.companyName,
    required this.companyCode,
  });

  factory CompanyWithAdminResult.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] as Map<String, dynamic>;
    return CompanyWithAdminResult(
      // access_token/token_type live at the top level of this response,
      // same keys TokenModel already expects.
      token: TokenModel.fromJson(json),
      admin: UserModel.fromJson(json['admin'] as Map<String, dynamic>),
      companyName: companyJson['name'] as String,
      companyCode: companyJson['company_code'] as String,
    );
  }
}