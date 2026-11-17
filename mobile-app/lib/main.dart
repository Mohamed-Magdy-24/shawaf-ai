import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/sites/presentation/cubit/site_cubit.dart';
import 'features/alerts/presentation/cubit/alert_inbox_cubit.dart';
import 'features/cameras/presentation/cubit/camera_stream_cubit.dart';
import 'features/cameras/presentation/cubit/camera_management_cubit.dart';
import 'features/employees/presentation/cubit/employee_cubit.dart';
import 'cubits/connectivity_cubit.dart';
import 'repositories/surveillance_repository.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const ShawafAiApp());
}

class ShawafAiApp extends StatelessWidget {
  final ApiService? apiService;
  final SurveillanceRepository? repository;
  final Widget? homeOverride;

  const ShawafAiApp({
    super.key,
    this.apiService,
    this.repository,
    this.homeOverride,
  });

  @override
  Widget build(BuildContext context) {
    setupServiceLocator();
    final repo = repository ?? sl<SurveillanceRepository>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SurveillanceRepository>.value(value: repo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: repo)),
          BlocProvider<SiteCubit>(create: (_) => SiteCubit(repository: repo)..loadSites()),
          BlocProvider<AlertInboxCubit>(create: (_) => AlertInboxCubit(repository: repo)),
          BlocProvider<CameraStreamCubit>(create: (_) => CameraStreamCubit(repository: repo)),
          BlocProvider<CameraManagementCubit>(create: (_) => CameraManagementCubit(repository: repo)),
          BlocProvider<EmployeeCubit>(create: (_) => EmployeeCubit(repository: repo)),
          BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
        ],
        child: homeOverride != null
            ? MaterialApp(
                title: 'Shawaf AI (شوف AI)',
                debugShowCheckedModeBanner: false,
                home: homeOverride,
              )
            : const ShawafApp(),
      ),
    );
  }
}
