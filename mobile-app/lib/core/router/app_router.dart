import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/alerts/presentation/pages/inbox_page.dart';
import '../../features/alerts/presentation/pages/alert_detail_page.dart';
import '../../features/cameras/presentation/pages/cameras_page.dart';
import '../../features/cameras/presentation/pages/add_camera_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../models/models.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/inbox',
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
        GoRoute(
          path: '/inbox',
          pageBuilder: (context, state) => const NoTransitionPage(child: InboxPage()),
        ),
        GoRoute(
          path: '/cameras',
          pageBuilder: (context, state) => const NoTransitionPage(child: CamerasPage()),
        ),
        GoRoute(
          path: '/employees',
          pageBuilder: (context, state) => const NoTransitionPage(child: EmployeesPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/alerts/:id',
      builder: (context, state) {
        final alert = state.extra as SurveillanceEvent?;
        if (alert == null) {
          return Scaffold(
            body: Center(
              child: Text('Incident ${state.pathParameters["id"]} not found'),
            ),
          );
        }
        return AlertDetailPage(event: alert);
      },
    ),
    GoRoute(
      path: '/cameras/add',
      builder: (context, state) => AddCameraPage(),
    ),
  ],
);
