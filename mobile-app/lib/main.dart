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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const ShawafAiApp());
}

class ShawafAiApp extends StatelessWidget {
  final Widget? homeOverride;

  const ShawafAiApp({
    super.key,
    this.homeOverride,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<SiteCubit>(create: (_) => sl<SiteCubit>()..loadSites()),
        BlocProvider<AlertInboxCubit>(create: (_) => sl<AlertInboxCubit>()),
        BlocProvider<CameraStreamCubit>(create: (_) => sl<CameraStreamCubit>()),
        BlocProvider<CameraManagementCubit>(create: (_) => sl<CameraManagementCubit>()),
        BlocProvider<EmployeeCubit>(create: (_) => sl<EmployeeCubit>()),
        BlocProvider<ConnectivityCubit>(create: (_) => sl<ConnectivityCubit>()),
      ],
      child: homeOverride != null
          ? MaterialApp(
              title: 'SHAWAF AI — Industrial Control Room',
              debugShowCheckedModeBanner: false,
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              home: homeOverride,
            )
          : const ShawafApp(),
    );
  }
}
