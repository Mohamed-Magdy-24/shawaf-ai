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

class ShawafAiApp extends StatefulWidget {
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
  State<ShawafAiApp> createState() => _ShawafAiAppState();
}

class _ShawafAiAppState extends State<ShawafAiApp> with WidgetsBindingObserver {
  late final SurveillanceRepository _repo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupServiceLocator();
    _repo = widget.repository ?? sl<SurveillanceRepository>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Cleanly pause WebSocket & active streaming on backgrounding
        _repo.disconnectWebSocket();
        break;
      case AppLifecycleState.resumed:
        // Reconnect on resumption
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SurveillanceRepository>.value(value: _repo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _repo)),
          BlocProvider<SiteCubit>(
              create: (_) => SiteCubit(repository: _repo)..loadSites()),
          BlocProvider<AlertInboxCubit>(
              create: (_) => AlertInboxCubit(repository: _repo)),
          BlocProvider<CameraStreamCubit>(
              create: (_) => CameraStreamCubit(repository: _repo)),
          BlocProvider<CameraManagementCubit>(
              create: (_) => CameraManagementCubit(repository: _repo)),
          BlocProvider<EmployeeCubit>(
              create: (_) => EmployeeCubit(repository: _repo)),
          BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
        ],
        child: widget.homeOverride != null
            ? MaterialApp(
                title: 'Shawaf AI',
                debugShowCheckedModeBanner: false,
                home: widget.homeOverride,
              )
            : const ShawafApp(),
      ),
    );
  }
}
