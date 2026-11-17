import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/alerts/presentation/pages/inbox_page.dart';
import '../../features/alerts/presentation/pages/alert_detail_page.dart';
import '../../features/cameras/presentation/pages/cameras_page.dart';
import '../../features/cameras/presentation/pages/add_camera_page.dart';
import '../../features/cameras/presentation/pages/camera_detail_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/employees/presentation/pages/employee_import_page.dart';
import '../../features/employees/presentation/pages/employee_presence_page.dart';
import '../../features/employees/presentation/pages/employee_detail_page.dart';
import '../../features/overview/presentation/pages/overview_page.dart';
import '../../features/operations/presentation/pages/live_control_page.dart';
import '../../features/operations/presentation/pages/camera_wall_page.dart';
import '../../features/infrastructure/presentation/pages/nvr_management_page.dart';
import '../../features/infrastructure/presentation/pages/sites_facilities_page.dart';
import '../../features/infrastructure/presentation/pages/safety_zones_page.dart';
import '../../features/system/presentation/pages/ai_analytics_page.dart';
import '../../features/system/presentation/pages/system_diagnostics_page.dart';
import '../../features/system/presentation/pages/audit_trail_page.dart';
import '../../features/system/presentation/pages/settings_page.dart';
import '../../features/security/presentation/pages/security_page.dart';
import '../../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/overview',
  redirect: (BuildContext context, GoRouterState state) {
    String? token;
    if (sl.isRegistered<IAuthRepository>()) {
      token = sl<IAuthRepository>().currentToken;
    }
    final isAuthenticated = token != null && token.isNotEmpty;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoggingIn) {
      return '/login';
    }
    if (isAuthenticated && isLoggingIn) {
      return '/overview';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        // Operations
        GoRoute(
          path: '/overview',
          pageBuilder: (context, state) => const NoTransitionPage(child: OverviewPage()),
        ),
        GoRoute(
          path: '/live-control',
          pageBuilder: (context, state) => const NoTransitionPage(child: LiveControlRoomPage()),
        ),
        GoRoute(
          path: '/camera-wall',
          pageBuilder: (context, state) => const NoTransitionPage(child: CameraWallPage()),
        ),
        GoRoute(
          path: '/inbox',
          pageBuilder: (context, state) => const NoTransitionPage(child: InboxPage()),
        ),
        GoRoute(
          path: '/employees',
          pageBuilder: (context, state) => const NoTransitionPage(child: EmployeesPage()),
        ),
        GoRoute(
          path: '/employees/presence',
          pageBuilder: (context, state) => const NoTransitionPage(child: EmployeePresencePage()),
        ),

        // Infrastructure
        GoRoute(
          path: '/cameras',
          pageBuilder: (context, state) => const NoTransitionPage(child: CamerasPage()),
        ),
        GoRoute(
          path: '/nvrs',
          pageBuilder: (context, state) => const NoTransitionPage(child: NvrManagementPage()),
        ),
        GoRoute(
          path: '/sites',
          pageBuilder: (context, state) => const NoTransitionPage(child: SitesFacilitiesPage()),
        ),
        GoRoute(
          path: '/zones',
          pageBuilder: (context, state) => const NoTransitionPage(child: SafetyZonesPage()),
        ),

        // Intelligence & System
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => const NoTransitionPage(child: AiAnalyticsPage()),
        ),
        GoRoute(
          path: '/diagnostics',
          pageBuilder: (context, state) => const NoTransitionPage(child: SystemDiagnosticsPage()),
        ),
        GoRoute(
          path: '/audit',
          pageBuilder: (context, state) => const NoTransitionPage(child: AuditTrailPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
        ),
        GoRoute(
          path: '/security',
          pageBuilder: (context, state) => const NoTransitionPage(child: SecurityPage()),
        ),
      ],
    ),
    // Contextual and Detail Routes
    GoRoute(
      path: '/employees/import',
      builder: (context, state) => const EmployeeImportPage(),
    ),
    GoRoute(
      path: '/alerts/:id',
      builder: (context, state) {
        final alert = state.extra as SurveillanceEvent?;
        if (alert == null) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: Center(
              child: Text('Incident ${state.pathParameters["id"]} not found', style: AppTypography.titleMedium),
            ),
          );
        }
        return AlertDetailPage(event: alert);
      },
    ),
    GoRoute(
      path: '/cameras/add',
      builder: (context, state) => const AddCameraPage(),
    ),
    GoRoute(
      path: '/cameras/:id',
      builder: (context, state) => CameraDetailPage(camera: state.extra as Camera?),
    ),
    GoRoute(
      path: '/employees/:id',
      builder: (context, state) => EmployeeDetailPage(employee: state.extra as Employee?),
    ),
  ],
);
