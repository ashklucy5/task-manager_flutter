// / Every backend endpoint path as a constant, matching the OpenAPI spec
// / exactly. Base URL comes from ApiConfig (.env) — these are just the
// / paths appended to it, so a request becomes:
// / `${ApiConfig.baseUrl}${ApiEndpoints.login}`
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const me = '/auth/me';

  // ── Users ─────────────────────────────────────────────────────
  static const usersMe = '/users/me';
  static const teamProfiles = '/users/team-profiles';
  static const heartbeat = '/users/me/heartbeat';
  static const updateStatus = '/users/me/status';
  static const setOffline = '/users/me/set-offline';
  static const updatePassword = '/users/me/password';
  static String userAvatar(String userId) => '/users/$userId/avatar';
  static String userById(String userId) => '/users/$userId';
  static const usersList = '/users/';
  static const usersLogout = '/users/logout';

  // ── Tasks ─────────────────────────────────────────────────────
  static const tasksMe = '/tasks/me';
  static String taskById(int taskId) => '/tasks/$taskId';
  static const tasksList = '/tasks/';
  static String taskStatus(int taskId) => '/tasks/$taskId/status';
  static String taskRequirements(int taskId) => '/tasks/$taskId/requirements';
  static String taskChecklist(int taskId) => '/tasks/$taskId/checklist';
  static String taskImages(int taskId) => '/tasks/$taskId/images';
  static String taskImage(int taskId) => '/tasks/$taskId/image';
  static String taskClientInfo(int taskId) => '/tasks/$taskId/client-info';
  static const tasksFinancial = '/tasks/financial';

  // ── Financials (SuperAdmin only) ─────────────────────────────
  static const financialsSummary = '/financials/summary';
  static const financialsUsers = '/financials/users';
  static const financialsTasks = '/financials/tasks';

  // ── Analytics (SuperAdmin only) ──────────────────────────────
  static const teamPerformance = '/analytics/team-performance';
  static const workloadBalance = '/analytics/workload-balance';

  // ── Companies ─────────────────────────────────────────────────
  static const companyWithAdmin = '/companies/with-admin';

  // ── Misc ──────────────────────────────────────────────────────
  static const health = '/health';
}