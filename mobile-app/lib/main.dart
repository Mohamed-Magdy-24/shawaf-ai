import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/alert_inbox_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/camera_management_cubit.dart';
import 'cubits/camera_stream_cubit.dart';
import 'cubits/connectivity_cubit.dart';
import 'cubits/employee_cubit.dart';
import 'cubits/site_cubit.dart';
import 'repositories/surveillance_repository.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final repository = HttpSurveillanceRepository(apiService: apiService);

  runApp(ShawafAiApp(
    apiService: apiService,
    repository: repository,
  ));
}

class ShawafAiApp extends StatelessWidget {
  final ApiService apiService;
  final SurveillanceRepository repository;
  final Widget? homeOverride;

  const ShawafAiApp({
    super.key,
    required this.apiService,
    required this.repository,
    this.homeOverride,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>.value(value: apiService),
        RepositoryProvider<SurveillanceRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(repository: repository),
          ),
          BlocProvider<SiteCubit>(
            create: (_) => SiteCubit(repository: repository),
          ),
          BlocProvider<AlertInboxCubit>(
            create: (_) => AlertInboxCubit(repository: repository),
          ),
          BlocProvider<CameraStreamCubit>(
            create: (_) => CameraStreamCubit(repository: repository),
          ),
          BlocProvider<CameraManagementCubit>(
            create: (_) => CameraManagementCubit(repository: repository),
          ),
          BlocProvider<EmployeeCubit>(
            create: (_) => EmployeeCubit(repository: repository),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (_) => ConnectivityCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Shawaf AI — Industrial Safety & Edge Surveillance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: homeOverride ?? const _AppRootNavigator(),
        ),
      ),
    );
  }
}

class _AppRootNavigator extends StatelessWidget {
  const _AppRootNavigator();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<SiteCubit>().loadSites();
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}
