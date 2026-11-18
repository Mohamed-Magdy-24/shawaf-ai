import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/network/websocket_client.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/responsive_main_layout.dart';
import 'features/incidents/data/incident_repository.dart';
import 'features/incidents/presentation/bloc/incident_bloc.dart';
import 'features/video/data/camera_repository.dart';
import 'features/video/presentation/bloc/camera_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8080');
  final wsClient = IndustrialWebSocketClient(
    baseWsUrl: 'ws://127.0.0.1:8080',
    siteId: 'BNF',
  );

  final incidentRepo = IncidentRepositoryImpl(
    apiClient: apiClient,
    webSocketClient: wsClient,
  );

  final cameraRepo = CameraRepositoryImpl(apiClient: apiClient);

  runApp(SurveillanceApp(
    incidentRepository: incidentRepo,
    cameraRepository: cameraRepo,
  ));
}

class SurveillanceApp extends StatelessWidget {
  final IncidentRepository incidentRepository;
  final CameraRepository cameraRepository;

  const SurveillanceApp({
    super.key,
    required this.incidentRepository,
    required this.cameraRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IncidentRepository>.value(value: incidentRepository),
        RepositoryProvider<CameraRepository>.value(value: cameraRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<IncidentBloc>(
            create: (context) => IncidentBloc(
              repository: incidentRepository,
              activeSiteId: 'BNF',
            ),
          ),
          BlocProvider<CameraBloc>(
            create: (context) => CameraBloc(
              repository: cameraRepository,
              activeSiteId: 'BNF',
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Industrial AI Surveillance — BNF / RNF',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.industrialDark,
          home: const ResponsiveMainLayout(initialSiteId: 'BNF'),
        ),
      ),
    );
  }
}
