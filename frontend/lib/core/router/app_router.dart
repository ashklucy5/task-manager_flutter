import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../enums/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_company_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/tasks/screens/task_list_screen.dart';
import '../../features/presence/screens/team_pulse_screen.dart';
import '../../features/presence/providers/heartbeat_provider.dart';
import '../../shared/dashboard/ceo_dashboard_screen.dart';
import '../../shared/dashboard/hr_dashboard_screen.dart';
import '../../shared/dashboard/member_dashboard_screen.dart';
import '../../features/tasks/screens/create_task_screen.dart';
import '../../features/team/screens/team_list_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/finance/screens/finance_dashboard_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/tasks/screens/edit_task_screen.dart';
import '../../shared/settings/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const registerCompany = '/register-company';

  static const home = '/home';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const createTask = '/tasks/create';
  static const editTask = '/tasks/:id/edit';
  static const pulse = '/pulse';
  static const team = '/team';
  static const finance = '/finance';
  static const analytics = '/analytics';
  static const profile = '/profile';
  static const changePassword = '/profile/change-password';
  static const notifications = '/notifications';
  static const settings = '/settings';

  static String taskDetailPath(int taskId) => '/tasks/$taskId';
  static String editTaskPath(int taskId) => '/tasks/$taskId/edit';
}

const _publicRoutes = {AppRoutes.splash, AppRoutes.login, AppRoutes.registerCompany};

const _superAdminOnlyRoutes = {AppRoutes.finance, AppRoutes.analytics};

const _managerRoutes = {AppRoutes.team, AppRoutes.createTask};

final routerProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authController,
    redirect: (context, state) {
      final status = authController.status;
      final role = authController.role;
      final goingTo = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return goingTo == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (goingTo == AppRoutes.splash) {
        return status == AuthStatus.authenticated ? AppRoutes.home : AppRoutes.login;
      }

      final isPublicRoute = _publicRoutes.contains(goingTo);

      if (status == AuthStatus.unauthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      if (status == AuthStatus.authenticated && isPublicRoute) {
        return AppRoutes.home;
      }

      if (status == AuthStatus.authenticated && role != null) {
        if (_superAdminOnlyRoutes.contains(goingTo) && role != UserRole.superAdmin) {
          return AppRoutes.home;
        }
        if (_managerRoutes.contains(goingTo) &&
            role != UserRole.superAdmin &&
            role != UserRole.admin) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerCompany,
        builder: (context, state) => const RegisterCompanyScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => _AppShell(
          currentPath: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const _HomeRouter(),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: AppRoutes.createTask,
            builder: (context, state) => const CreateTaskScreen(),
          ),
          GoRoute(
            path: AppRoutes.taskDetail,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(body: Center(child: Text('Invalid task')));
              }
              return TaskDetailScreen(taskId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.editTask,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(body: Center(child: Text('Invalid task')));
              }
              return EditTaskScreen(taskId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.pulse,
            builder: (context, state) => const TeamPulseScreen(),
          ),
          GoRoute(
            path: AppRoutes.team,
            builder: (context, state) => const TeamListScreen(),
          ),
          GoRoute(
            path: AppRoutes.finance,
            builder: (context, state) => const FinanceDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.changePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const _PlaceholderScreen(name: 'Notifications'),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}

class _HomeRouter extends ConsumerWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).role;
    debugPrint('🔍 Home role: $role');
    switch (role) {
      case UserRole.superAdmin:
        return const CeoDashboardScreen();
      case UserRole.admin:
        return const HrDashboardScreen();
      case UserRole.member:
      case null:
        return const MemberDashboardScreen();
    }
  }
}

class _AppShell extends ConsumerWidget {
  final String currentPath;
  final Widget child;

  const _AppShell({required this.currentPath, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).role;

    final destinations = _navDestinationsFor(role);

    final currentIndex = destinations.indexWhere((d) => d.path == currentPath);

    return HeartbeatLifecycleObserver(
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => context.go(destinations[index].path),
          items: destinations
              .map((d) => BottomNavigationBarItem(icon: Icon(d.icon), label: d.label))
              .toList(),
        ),
      ),
    );
  }

  List<_NavDestination> _navDestinationsFor(UserRole? role) {
    switch (role) {
      case UserRole.superAdmin:
        return const [
          _NavDestination(AppRoutes.home, 'Home', Icons.home_outlined),
          _NavDestination(AppRoutes.tasks, 'Tasks', Icons.check_circle_outline),
          _NavDestination(AppRoutes.pulse, 'Pulse', Icons.podcasts_outlined),
          _NavDestination(AppRoutes.finance, 'Finance', Icons.attach_money),
          _NavDestination(AppRoutes.profile, 'Profile', Icons.person_outline),
        ];
      case UserRole.admin:
        return const [
          _NavDestination(AppRoutes.home, 'Home', Icons.home_outlined),
          _NavDestination(AppRoutes.tasks, 'Tasks', Icons.check_circle_outline),
          _NavDestination(AppRoutes.pulse, 'Pulse', Icons.podcasts_outlined),
          _NavDestination(AppRoutes.team, 'Team', Icons.groups_outlined),
          _NavDestination(AppRoutes.profile, 'Profile', Icons.person_outline),
        ];
      case UserRole.member:
      case null:
        return const [
          _NavDestination(AppRoutes.home, 'Home', Icons.home_outlined),
          _NavDestination(AppRoutes.tasks, 'Tasks', Icons.check_circle_outline),
          _NavDestination(AppRoutes.pulse, 'Pulse', Icons.podcasts_outlined),
          _NavDestination(AppRoutes.profile, 'Profile', Icons.person_outline),
        ];
    }
  }
}

class _NavDestination {
  final String path;
  final String label;
  final IconData icon;
  const _NavDestination(this.path, this.label, this.icon);
}